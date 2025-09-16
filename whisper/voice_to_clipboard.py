#!/usr/bin/env python3
import subprocess
import tempfile
import os
import time
import sys
import threading
import queue

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

def record_and_transcribe_stream():
    """Record audio and transcribe in real-time using streaming with threading"""
    print("🎤 Recording and transcribing...")
    print("Enter: stop")
    print("Esc: quit")
    print("C: clear cache")
    print("")

    try:
        import select
        import termios
        import tty
        from faster_whisper import WhisperModel

        # Shared state between threads
        stop_event = threading.Event()
        transcription_queue = queue.Queue()
        error_queue = queue.Queue()

        # Create temporary file for audio buffer
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as temp_file:
            temp_path = temp_file.name

        def recording_thread():
            """Thread for recording audio to file with silence detection"""
            try:
                # Try sox with silence detection first
                try:
                    process = subprocess.Popen([
                        'sox', '-t', 'alsa', 'default', '-r', '44100', '-c', '2', '-b', '16',
                        temp_path,
                        'trim', '0',
                        'silence', '1', '0.1', '3%', '1', '2.0', '3%'
                    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

                    while not stop_event.is_set():
                        if process.poll() is not None:
                            # Sox finished naturally (silence detected)
                            print("\nSilence detected, stopping...")
                            stop_event.set()
                            break
                        time.sleep(0.1)

                except (subprocess.CalledProcessError, FileNotFoundError):
                    # Fallback to arecord if sox not available
                    process = subprocess.Popen([
                        'arecord', '-f', 'cd', '-t', 'wav', temp_path
                    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

                    while not stop_event.is_set():
                        if process.poll() is not None:
                            break
                        time.sleep(0.1)

                if process.poll() is None:
                    process.terminate()
                    process.wait()
            except Exception as e:
                error_queue.put(f"Recording error: {e}")

        def transcription_thread():
            """Thread for transcribing audio as it's recorded"""
            try:
                # Use base model for better accuracy with technical terms
                model = WhisperModel("base", device="cpu", compute_type="int8")

                transcription = ""
                last_size = 0

                while not stop_event.is_set():
                    try:
                        # Check if file has grown
                        if os.path.exists(temp_path):
                            current_size = os.path.getsize(temp_path)
                            if current_size > last_size and current_size > 1024:  # Wait for some data
                                # Transcribe the current file content
                                segments, info = model.transcribe(temp_path, beam_size=5)

                                new_transcription = ""
                                for segment in segments:
                                    new_transcription += segment.text

                                # Only update transcription, don't show partial results
                                if len(new_transcription) > len(transcription):
                                    transcription = new_transcription

                                last_size = current_size
                    except Exception as e:
                        # Ignore transcription errors during recording
                        pass

                    time.sleep(0.5)  # Check every 500ms

                # Final transcription
                if os.path.exists(temp_path):
                    segments, info = model.transcribe(temp_path, beam_size=5)
                    final_transcription = ""
                    for segment in segments:
                        final_transcription += segment.text
                    transcription_queue.put(final_transcription.strip())

            except Exception as e:
                error_queue.put(f"Transcription error: {e}")

        def input_thread():
            """Thread for handling keyboard input"""
            try:
                import select
                import termios
                import tty

                # Save terminal settings
                old_settings = termios.tcgetattr(sys.stdin)
                tty.setraw(sys.stdin.fileno())

                try:
                    while not stop_event.is_set():
                        if sys.stdin in select.select([sys.stdin], [], [], 0.1)[0]:
                            key = sys.stdin.read(1)
                            if key == '\r' or key == '\n':  # Enter
                                print("\nStopping...")
                                stop_event.set()
                                break
                            elif key == '\x1b':  # Escape
                                print("\nCancelled")
                                stop_event.set()
                                if os.path.exists(temp_path):
                                    os.unlink(temp_path)
                                sys.exit(0)
                            elif key.lower() == 'c':  # C to clear cache
                                print("\nClearing cache...")
                                clear_cache()
                                stop_event.set()
                                if os.path.exists(temp_path):
                                    os.unlink(temp_path)
                                sys.exit(0)
                finally:
                    # Restore terminal settings
                    termios.tcsetattr(sys.stdin, termios.TCSADRAIN, old_settings)

            except Exception as e:
                error_queue.put(f"Input error: {e}")

        # Start all threads
        rec_thread = threading.Thread(target=recording_thread)
        trans_thread = threading.Thread(target=transcription_thread)
        inp_thread = threading.Thread(target=input_thread)

        rec_thread.start()
        trans_thread.start()
        inp_thread.start()

        # Wait for threads to complete
        inp_thread.join()
        rec_thread.join()
        trans_thread.join()

        # Check for errors
        if not error_queue.empty():
            error = error_queue.get()
            print(f"Error: {error}")
            if os.path.exists(temp_path):
                os.unlink(temp_path)
            return None

        # Get final transcription
        if not transcription_queue.empty():
            final_transcription = transcription_queue.get()
            if os.path.exists(temp_path):
                os.unlink(temp_path)
            return final_transcription

        # Clean up
        if os.path.exists(temp_path):
            os.unlink(temp_path)
        return None

    except Exception as e:
        print(f"Streaming failed: {e}")
        return None

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

        # Try streaming transcription first
        transcription = record_and_transcribe_stream()

        # Fallback to file-based if streaming fails
        if transcription is None:
            audio_file = record_audio()
            transcription = transcribe_audio(audio_file)
            # Clean up temporary file
            if os.path.exists(audio_file):
                os.unlink(audio_file)

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
        # Clean up temporary file if it exists
        if 'audio_file' in locals() and os.path.exists(audio_file):
            os.unlink(audio_file)

if __name__ == "__main__":
    main()