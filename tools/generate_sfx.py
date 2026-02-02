#!/usr/bin/env python3
# ABOUTME: Generates 9 retro 8-bit sfxr-style .wav sound effects for breakout game
# ABOUTME: Uses pure Python (wave + struct + math) with no external dependencies

import wave
import struct
import math
import random
import os

SAMPLE_RATE = 44100
OUTPUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets", "audio")


def write_wav(filename, samples, sample_rate=SAMPLE_RATE):
    """Write 16-bit mono WAV file from float samples (-1.0 to 1.0)."""
    filepath = os.path.join(OUTPUT_DIR, filename)
    with wave.open(filepath, "w") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(sample_rate)
        for s in samples:
            clamped = max(-1.0, min(1.0, s))
            f.writeframes(struct.pack("<h", int(clamped * 32767)))
    print(f"  {filepath}")


def square_wave(t, freq):
    """Square wave oscillator."""
    return 1.0 if (t * freq) % 1.0 < 0.5 else -1.0


def saw_wave(t, freq):
    """Sawtooth wave oscillator."""
    return 2.0 * ((t * freq) % 1.0) - 1.0


def triangle_wave(t, freq):
    """Triangle wave oscillator."""
    phase = (t * freq) % 1.0
    return 4.0 * abs(phase - 0.5) - 1.0


def noise():
    """White noise sample."""
    return random.uniform(-1.0, 1.0)


def envelope(t, attack, sustain, decay, total_duration):
    """ADSR envelope (no separate release -- decay to zero)."""
    if t < attack:
        return t / attack if attack > 0 else 1.0
    elif t < attack + sustain:
        return 1.0
    elif t < attack + sustain + decay:
        return 1.0 - (t - attack - sustain) / decay
    else:
        return 0.0


def generate_paddle_hit():
    """Short ping/blip -- square wave with quick pitch drop."""
    duration = 0.12
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        freq = 800 - 400 * (t / duration)
        env = envelope(t, 0.0, 0.02, 0.10, duration)
        samples.append(square_wave(t, freq) * env * 0.6)
    return samples


def generate_brick_break():
    """Crunch/shatter -- noise burst with pitch sweep."""
    duration = 0.18
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        freq = 600 - 500 * (t / duration)
        env = envelope(t, 0.0, 0.03, 0.15, duration)
        # Mix square wave with noise for crunch
        sample = (square_wave(t, freq) * 0.4 + noise() * 0.6) * env * 0.7
        samples.append(sample)
    return samples


def generate_brick_hit():
    """Softer tap/tick -- short triangle blip."""
    duration = 0.08
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        freq = 500 - 200 * (t / duration)
        env = envelope(t, 0.0, 0.01, 0.07, duration)
        samples.append(triangle_wave(t, freq) * env * 0.5)
    return samples


def generate_wall_bounce():
    """Short bounce blip -- square with quick pitch up then down."""
    duration = 0.08
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        progress = t / duration
        # Pitch peaks at 30% through the sound
        if progress < 0.3:
            freq = 300 + 400 * (progress / 0.3)
        else:
            freq = 700 - 300 * ((progress - 0.3) / 0.7)
        env = envelope(t, 0.0, 0.01, 0.07, duration)
        samples.append(square_wave(t, freq) * env * 0.4)
    return samples


def generate_ball_launch():
    """Ascending blip -- square sweep up."""
    duration = 0.15
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        freq = 200 + 600 * (t / duration)
        env = envelope(t, 0.01, 0.05, 0.09, duration)
        samples.append(square_wave(t, freq) * env * 0.5)
    return samples


def generate_life_lost():
    """Descending sad tone -- saw wave dropping pitch."""
    duration = 0.5
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        freq = 400 * math.pow(0.3, t / duration)
        env = envelope(t, 0.0, 0.1, 0.4, duration)
        samples.append(saw_wave(t, freq) * env * 0.5)
    return samples


def generate_game_over():
    """Low descending multi-tone -- three descending notes."""
    duration = 0.8
    samples = []
    notes = [(300, 0.0, 0.25), (220, 0.25, 0.25), (150, 0.5, 0.30)]
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        sample = 0.0
        for freq, start, length in notes:
            if start <= t < start + length:
                local_t = t - start
                env = envelope(local_t, 0.01, length * 0.3, length * 0.69, length)
                sample += saw_wave(t, freq) * env * 0.4
        samples.append(sample)
    return samples


def generate_win():
    """Ascending fanfare jingle -- three ascending notes."""
    duration = 0.6
    samples = []
    notes = [(400, 0.0, 0.18), (500, 0.18, 0.18), (700, 0.36, 0.24)]
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        sample = 0.0
        for freq, start, length in notes:
            if start <= t < start + length:
                local_t = t - start
                env = envelope(local_t, 0.01, length * 0.4, length * 0.59, length)
                sample += square_wave(t, freq) * env * 0.5
        samples.append(sample)
    return samples


def generate_ui_click():
    """Short click -- very short square pulse."""
    duration = 0.05
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        freq = 1000 - 500 * (t / duration)
        env = envelope(t, 0.0, 0.005, 0.045, duration)
        samples.append(square_wave(t, freq) * env * 0.4)
    return samples


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    sounds = {
        "paddle_hit.wav": generate_paddle_hit,
        "brick_break.wav": generate_brick_break,
        "brick_hit.wav": generate_brick_hit,
        "wall_bounce.wav": generate_wall_bounce,
        "ball_launch.wav": generate_ball_launch,
        "life_lost.wav": generate_life_lost,
        "game_over.wav": generate_game_over,
        "win.wav": generate_win,
        "ui_click.wav": generate_ui_click,
    }

    print(f"Generating {len(sounds)} sound effects...")
    # Seed for reproducibility
    random.seed(42)
    for filename, generator in sounds.items():
        write_wav(filename, generator())
    print("Done.")


if __name__ == "__main__":
    main()
