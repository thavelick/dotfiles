#!/usr/bin/env python3
"""Voice input script that records audio and transcribes it using Whisper."""
import subprocess
import tempfile
import os
import time
import sys
import threading
import queue
import select
import termios
import tty
import logging
import traceback
from faster_whisper import WhisperModel
import av

ENTER_KEYS = ("\r", "\n")
ESCAPE_KEY = "\x1b"
CLEAR_KEY = "c"


def setup_logging():
    """Set up logging for transcription errors."""
    log_dir = os.path.expanduser("~/.cache")
    os.makedirs(log_dir, exist_ok=True)
    log_file = os.path.join(log_dir, "voice_input_errors.log")

    logging.basicConfig(
        filename=log_file,
        level=logging.ERROR,
        format="%(asctime)s - %(levelname)s - %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    return logging.getLogger(__name__)


def run_command(cmd, **kwargs):
    """Helper function to run subprocess commands with common defaults."""
    defaults = {"capture_output": True, "text": True, "check": False}
    defaults.update(kwargs)
    return subprocess.run(cmd, **defaults)


def record_and_transcribe_stream():
    """Record audio and transcribe in real-time using streaming with threading"""
    print("🎤 Recording and transcribing...")
    print("Enter: stop")
    print("Esc: quit")
    print("C: clear cache")
    print("")

    stop_event = threading.Event()
    transcription_queue = queue.Queue()

    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as temp_file:
        temp_path = temp_file.name

    def recording_thread():
        """Thread for recording audio with sox silence detection"""
        process = subprocess.Popen(
            [
                "sox",
                "-t",
                "alsa",
                "default",
                "-r",
                "44100",
                "-c",
                "2",
                "-b",
                "16",
                temp_path,
                "trim",
                "0",
                "silence",
                "1",
                "0.1",
                "3%",
                "1",
                "2.0",
                "3%",
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

        while not stop_event.is_set():
            if process.poll() is not None:
                print("\nSilence detected, stopping...")
                stop_event.set()
                break
            time.sleep(0.1)

        if process.poll() is None:
            process.terminate()
            process.wait()

    def transcription_thread():
        """Thread for transcribing audio as it's recorded"""
        logger = setup_logging()
        try:
            model = WhisperModel("base", device="cpu", compute_type="int8")

            transcription = ""
            last_size = 0

            while not stop_event.is_set():
                try:
                    if os.path.exists(temp_path):
                        current_size = os.path.getsize(temp_path)
                        if current_size > last_size and current_size > 8192:
                            print(".", end="", flush=True)
                            # Avoid reading file while sox is writing
                            time.sleep(0.1)
                            segments, _ = model.transcribe(temp_path, beam_size=5)

                            new_transcription = ""
                            for segment in segments:
                                new_transcription += segment.text

                            if len(new_transcription) > len(transcription):
                                transcription = new_transcription

                            last_size = current_size
                except av.error.ValueError:
                    # Ignore race condition when reading file while sox writes
                    continue
                except Exception as e:
                    logger.error(
                        f"Transcription chunk error: {e}\n{traceback.format_exc()}"
                    )
                    print("!", end="", flush=True)

                time.sleep(2.0)

            if os.path.exists(temp_path):
                current_size = os.path.getsize(temp_path)
                if current_size > last_size and current_size > 0:
                    print(".", end="", flush=True)
                    segments, _ = model.transcribe(temp_path, beam_size=5)

                    new_transcription = ""
                    for segment in segments:
                        new_transcription += segment.text

                    if len(new_transcription) > len(transcription):
                        transcription = new_transcription

            if transcription:
                transcription_queue.put(transcription.strip())
        except Exception as e:
            logger.error(f"Fatal transcription error: {e}\n{traceback.format_exc()}")
            print(f"\nTranscription failed: {e}")
            transcription_queue.put("")

    def input_thread():
        """Thread for handling keyboard input"""
        old_settings = termios.tcgetattr(sys.stdin)
        tty.setraw(sys.stdin.fileno())

        try:
            while not stop_event.is_set():
                if sys.stdin in select.select([sys.stdin], [], [], 0.1)[0]:
                    key = sys.stdin.read(1)
                    if key in ENTER_KEYS:
                        print("\nStopping...")
                        stop_event.set()
                        break
                    elif key == ESCAPE_KEY:
                        print("\nCancelled")
                        stop_event.set()
                        if os.path.exists(temp_path):
                            os.unlink(temp_path)
                        sys.exit(0)
                    elif key.lower() == CLEAR_KEY:
                        print("\nClearing cache...")
                        clear_cache()
                        stop_event.set()
                        if os.path.exists(temp_path):
                            os.unlink(temp_path)
                        sys.exit(0)
        finally:
            termios.tcsetattr(sys.stdin, termios.TCSADRAIN, old_settings)

    rec_thread = threading.Thread(target=recording_thread)
    trans_thread = threading.Thread(target=transcription_thread)
    inp_thread = threading.Thread(target=input_thread)

    rec_thread.start()
    trans_thread.start()
    inp_thread.start()

    inp_thread.join()
    rec_thread.join()
    trans_thread.join()

    if not transcription_queue.empty():
        final_transcription = transcription_queue.get()
        if os.path.exists(temp_path):
            os.unlink(temp_path)
        return final_transcription

    if os.path.exists(temp_path):
        os.unlink(temp_path)
    return None


def get_cached_pane():
    """Get cached tmux pane choice"""
    cache_file = os.path.expanduser("~/.cache/voice_tmux_pane")
    if os.path.exists(cache_file):
        with open(cache_file, "r", encoding="utf-8") as f:
            return f.read().strip()
    return None


def cache_pane(pane):
    """Cache tmux pane choice"""
    cache_dir = os.path.expanduser("~/.cache")
    os.makedirs(cache_dir, exist_ok=True)
    cache_file = os.path.join(cache_dir, "voice_tmux_pane")
    with open(cache_file, "w", encoding="utf-8") as f:
        f.write(pane)


def clear_cache():
    """Clear cached tmux pane"""
    cache_file = os.path.expanduser("~/.cache/voice_tmux_pane")
    if os.path.exists(cache_file):
        os.unlink(cache_file)
        print("Cache cleared!")


def select_tmux_pane():
    """Let user select tmux pane with fzf"""
    result = run_command(
        [
            "tmux",
            "list-panes",
            "-a",
            "-F",
            "#{session_name}:#{window_index}.#{pane_index} - "
            "#{window_name} (#{pane_current_command})",
        ]
    )
    if result.returncode != 0:
        return None

    panes = result.stdout.strip().split("\n")
    if len(panes) == 1:
        return panes[0].split(" - ")[0]

    fzf_process = run_command(
        ["fzf", "--prompt=Select tmux pane: "],
        input=result.stdout,
    )
    if fzf_process.returncode == 0:
        selected = fzf_process.stdout.strip().split(" - ")[0]
        cache_pane(selected)
        return selected
    return None


def get_target_pane():
    """Get or select target tmux pane"""
    result = run_command(["tmux", "list-sessions"])
    if result.returncode != 0:
        return None

    target_pane = get_cached_pane()

    if target_pane:
        pane_result = run_command(
            [
                "tmux",
                "list-panes",
                "-a",
                "-F",
                "#{session_name}:#{window_index}.#{pane_index}",
            ]
        )
        if pane_result.returncode == 0:
            pane_exists = target_pane in pane_result.stdout
            if not pane_exists:
                target_pane = None
        else:
            target_pane = None

    if not target_pane:
        target_pane = select_tmux_pane()

    return target_pane


def send_to_tmux(text, pane):
    """Send text to specified tmux pane"""
    run_command(["tmux", "send-keys", "-t", pane, text], check=True)


def copy_to_clipboard(text):
    """Copy text to clipboard using wl-copy"""
    run_command(["wl-copy"], input=text.encode(), check=True)


def main():
    """Main entry point for the voice input application."""
    print("Voice to Clipboard")
    print("==================")
    print("")

    target_pane = get_target_pane()
    use_tmux = target_pane is not None

    transcription = record_and_transcribe_stream()

    if transcription:
        if use_tmux:
            send_to_tmux(transcription, target_pane)
            print(f"Sent to tmux: {transcription}")
        else:
            copy_to_clipboard(transcription)
            print(f"Copied to clipboard: {transcription}")


if __name__ == "__main__":
    main()
