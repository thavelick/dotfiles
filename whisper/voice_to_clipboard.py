#!/usr/bin/env python3
import subprocess
import tempfile
import os
import time
import sys

def handle_key_input(key, process, temp_path):
    """Handle keyboard input during recording"""
    if key == '\r' or key == '\n':  # Enter
        process.terminate()
        process.wait()
        print("\nTranscribing...")
        return 'stop'
    elif key == '\x1b':  # Escape
        process.terminate()
        process.wait()
        os.unlink(temp_path)
        print("\nCancelled")
        sys.exit(0)
    elif key.lower() == 'c':  # C to clear cache
        process.terminate()
        process.wait()
        os.unlink(temp_path)
        clear_cache()
        sys.exit(0)
    return 'continue'

def record_audio():
    """Record audio with sox silence detection, fallback to manual recording"""
    print("🎤 Recording...")
    print("Enter: stop")
    print("Esc: quit")
    print("C: clear cache")
    print("")

    # Create temporary file
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as temp_file:
        temp_path = temp_file.name

    # Try sox with silence detection first
    try:
        import select
        import termios
        import tty

        # Start sox recording in background
        process = subprocess.Popen([
            'sox', '-t', 'alsa', 'default', '-r', '44100', '-c', '2', '-b', '16',
            temp_path,
            'trim', '0',
            'silence', '1', '0.1', '3%', '1', '2.0', '3%'
        ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        return _handle_recording_with_input(process, temp_path, check_running=True)

    except (subprocess.CalledProcessError, FileNotFoundError, ImportError):
        # Fallback to manual recording
        try:
            import select
            import termios
            import tty

            process = subprocess.Popen([
                'arecord', '-f', 'cd', '-t', 'wav', temp_path
            ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

            return _handle_recording_with_input(process, temp_path, check_running=False)

        except ImportError:
            # Final fallback to simple input
            process = subprocess.Popen([
                'arecord', '-f', 'cd', '-t', 'wav', temp_path
            ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

            input()
            process.terminate()
            process.wait()
            print("Transcribing...")
            return temp_path

def _handle_recording_with_input(process, temp_path, check_running=True):
    """Handle recording with keyboard input monitoring"""
    import select
    import termios
    import tty

    # Save terminal settings
    old_settings = termios.tcgetattr(sys.stdin)
    tty.setraw(sys.stdin.fileno())

    try:
        if check_running:
            # Sox mode - check if process is still running
            while process.poll() is None:
                if sys.stdin in select.select([sys.stdin], [], [], 0)[0]:
                    key = sys.stdin.read(1)
                    result = handle_key_input(key, process, temp_path)
                    if result == 'stop':
                        return temp_path
                time.sleep(0.1)
        else:
            # Manual mode - wait for user input
            while True:
                if sys.stdin in select.select([sys.stdin], [], [], 0.1)[0]:
                    key = sys.stdin.read(1)
                    result = handle_key_input(key, process, temp_path)
                    if result == 'stop':
                        break
    finally:
        # Restore terminal settings
        termios.tcsetattr(sys.stdin, termios.TCSADRAIN, old_settings)

    # Stop recording if still running
    if process.poll() is None:
        process.terminate()
        process.wait()

    print("Transcribing...")
    return temp_path

def transcribe_audio(audio_file):
    """Transcribe audio using faster-whisper"""
    # Import here to avoid startup delay if not needed
    try:
        from faster_whisper import WhisperModel
    except ImportError:
        return None

    start_time = time.time()

    # Use base model for better accuracy with technical terms
    model = WhisperModel("base", device="cpu", compute_type="int8")

    segments, info = model.transcribe(audio_file, beam_size=5)

    transcription = ""
    for segment in segments:
        transcription += segment.text

    print("Done")

    return transcription.strip()

def get_cached_pane():
    """Get cached tmux pane choice"""
    cache_file = os.path.expanduser("~/.cache/voice_tmux_pane")
    if os.path.exists(cache_file):
        with open(cache_file, 'r') as f:
            return f.read().strip()
    return None

def cache_pane(pane):
    """Cache tmux pane choice"""
    cache_dir = os.path.expanduser("~/.cache")
    os.makedirs(cache_dir, exist_ok=True)
    cache_file = os.path.join(cache_dir, "voice_tmux_pane")
    with open(cache_file, 'w') as f:
        f.write(pane)

def clear_cache():
    """Clear cached tmux pane"""
    cache_file = os.path.expanduser("~/.cache/voice_tmux_pane")
    if os.path.exists(cache_file):
        os.unlink(cache_file)
        print("Cache cleared!")

def select_tmux_pane():
    """Let user select tmux pane with fzf"""
    try:
        # Get list of panes with session and window info
        result = subprocess.run(['tmux', 'list-panes', '-a', '-F', '#{session_name}:#{window_index}.#{pane_index} - #{window_name} (#{pane_current_command})'], capture_output=True, text=True)
        if result.returncode != 0:
            return None

        panes = result.stdout.strip().split('\n')
        if len(panes) == 1:
            return panes[0].split(' - ')[0]

        # Use fzf to select pane
        fzf_process = subprocess.run(['fzf', '--prompt=Select tmux pane: '],
                                   input=result.stdout, text=True, capture_output=True)
        if fzf_process.returncode == 0:
            selected = fzf_process.stdout.strip().split(' - ')[0]
            cache_pane(selected)
            return selected
        return None
    except:
        return None

def get_target_pane():
    """Get or select target tmux pane"""
    try:
        # Check if tmux sessions exist
        result = subprocess.run(['tmux', 'list-sessions'], capture_output=True, text=True)
        if result.returncode != 0:
            return None

        # Try cached pane first
        target_pane = get_cached_pane()

        # Verify cached pane still exists
        if target_pane:
            pane_result = subprocess.run(['tmux', 'list-panes', '-a', '-F', '#{session_name}:#{window_index}.#{pane_index}'], capture_output=True, text=True)
            if pane_result.returncode == 0:
                pane_exists = target_pane in pane_result.stdout
                if not pane_exists:
                    target_pane = None
            else:
                target_pane = None

        # If no valid cached pane, let user select
        if not target_pane:
            target_pane = select_tmux_pane()

        return target_pane
    except:
        return None

def send_to_tmux(text, pane):
    """Send text to specified tmux pane"""
    try:
        subprocess.run(['tmux', 'send-keys', '-t', pane, text], check=True)
        return True
    except:
        return False

def copy_to_clipboard(text):
    """Copy text to clipboard using wl-copy"""
    try:
        subprocess.run(['wl-copy'], input=text.encode(), check=True)
        return True
    except:
        return False

def main():
    print("Voice to Clipboard")
    print("==================")
    print("")

    try:
        # Determine target before recording
        target_pane = get_target_pane()
        use_tmux = target_pane is not None

        # Record audio
        audio_file = record_audio()

        # Transcribe
        transcription = transcribe_audio(audio_file)

        # Send to tmux or copy to clipboard
        if transcription:
            if use_tmux and send_to_tmux(transcription, target_pane):
                print(f"Sent to tmux: {transcription}")
            else:
                copy_to_clipboard(transcription)
                print(f"Copied to clipboard: {transcription}")

    except KeyboardInterrupt:
        pass
    finally:
        # Clean up temporary file
        if 'audio_file' in locals() and os.path.exists(audio_file):
            os.unlink(audio_file)

if __name__ == "__main__":
    main()