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
    # Set USE_CONSERVATIVE=1 environment variable to use memory-optimized wrapper
    use_conservative = os.environ.get('USE_CONSERVATIVE', '0') == '1'
    wrapper_name = "sadtalker_wrapper_conservative.py" if use_conservative else "sadtalker_wrapper.py"
    wrapper_script = Path(__file__).parent / wrapper_name

    if use_conservative:
        print("🛡️  Using conservative wrapper (memory-optimized)")

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
        # Stream output in real-time instead of buffering
        result = subprocess.run(
            cmd,
            cwd=str(SADTALKER_DIR),  # Run from sadtalker directory
            check=True  # Removed capture_output to stream in real-time
        )

        print(f"✅ Video generated successfully: {output_path}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error generating video (exit code {e.returncode})", file=sys.stderr)
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
