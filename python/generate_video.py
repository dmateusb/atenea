#!/usr/bin/env python3
"""
SadTalker video generation script optimized for M3 Mac
"""
import sys
import os
import argparse
import torch
import subprocess
from pathlib import Path

# SadTalker directory
SADTALKER_DIR = Path(__file__).parent.parent / "sadtalker"

def check_device():
    """Check available device (CUDA > CPU, skip MPS due to compatibility)"""
    if torch.cuda.is_available():
        device = "cuda"
        gpu_name = torch.cuda.get_device_name(0)
        print(f"✅ CUDA GPU detected: {gpu_name}")
        return device, 512  # High quality for GPU
    elif torch.backends.mps.is_available():
        print("⚠️  MPS available but not used due to SadTalker compatibility issues")
        print("    Using CPU instead for stable inference")
        return "cpu", 384  # Balanced for Mac CPU
    else:
        print("⚠️  No GPU detected, using CPU")
        return "cpu", 384  # Balanced for CPU

def generate_video(image_path: str, audio_path: str, output_path: str):
    """
    Generate talking head video using SadTalker

    Args:
        image_path: Path to source image (avatar)
        audio_path: Path to audio file
        output_path: Path for output video
    """
    # Check device and select appropriate resolution
    device, video_size = check_device()

    print(f"🎬 Generating video with device: {device}")
    print(f"📐 Resolution: {video_size}x{video_size}")
    print(f"📸 Image: {image_path}")
    print(f"🎵 Audio: {audio_path}")
    print(f"🎥 Output: {output_path}")

    # Use the wrapper script (in python/ directory, will be in repo)
    wrapper_script = Path(__file__).parent / "sadtalker_wrapper.py"
    checkpoint_dir = SADTALKER_DIR / "checkpoints"

    # Call the wrapper script as a subprocess
    cmd = [
        sys.executable,  # Use same Python interpreter
        str(wrapper_script),
        '--image', image_path,
        '--audio', audio_path,
        '--output', output_path,
        '--checkpoint-dir', str(checkpoint_dir),
        '--device', device,
        '--size', str(video_size),  # Auto-selected based on device (512 for GPU, 384 for CPU)
    ]

    try:
        result = subprocess.run(
            cmd,
            cwd=str(SADTALKER_DIR),  # Run from sadtalker directory
            capture_output=True,
            text=True,
            check=True
        )

        # Print output
        if result.stdout:
            print(result.stdout)

        print(f"✅ Video generated successfully: {output_path}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error generating video:", file=sys.stderr)
        if e.stdout:
            print(e.stdout, file=sys.stderr)
        if e.stderr:
            print(e.stderr, file=sys.stderr)
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}", file=sys.stderr)
        return False

def main():
    parser = argparse.ArgumentParser(description='Generate talking head video')
    parser.add_argument('--image', required=True, help='Path to source image')
    parser.add_argument('--audio', required=True, help='Path to audio file')
    parser.add_argument('--output', required=True, help='Path for output video')

    args = parser.parse_args()

    # Validate inputs
    if not os.path.exists(args.image):
        print(f"❌ Image not found: {args.image}", file=sys.stderr)
        sys.exit(1)

    if not os.path.exists(args.audio):
        print(f"❌ Audio not found: {args.audio}", file=sys.stderr)
        sys.exit(1)

    # Create output directory
    os.makedirs(os.path.dirname(args.output), exist_ok=True)

    # Generate video
    success = generate_video(args.image, args.audio, args.output)
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
