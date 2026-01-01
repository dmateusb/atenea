#!/usr/bin/env python3
"""
Wrapper script for SadTalker inference.
Adds SadTalker to Python path and calls inference.
"""
import sys
import os
from pathlib import Path
from argparse import ArgumentParser

# Add SadTalker directory to Python path
SADTALKER_DIR = Path(__file__).parent.parent / "sadtalker"
sys.path.insert(0, str(SADTALKER_DIR))

# CRITICAL: Set sys.argv[0] to point to inference.py in sadtalker directory
# This is needed because SadTalker uses sys.argv[0] to determine its root path
sys.argv[0] = str(SADTALKER_DIR / "inference.py")

# Import SadTalker's main function
from inference import main as sadtalker_inference

def main():
    """Parse arguments and call SadTalker inference"""
    parser = ArgumentParser(description='SadTalker wrapper for video generation')
    parser.add_argument('--image', required=True, help='Path to source image')
    parser.add_argument('--audio', required=True, help='Path to audio file')
    parser.add_argument('--output', required=True, help='Path for output video')
    parser.add_argument('--checkpoint-dir', required=True, help='Path to checkpoints directory')
    parser.add_argument('--device', default='cpu', help='Device to use (cpu, mps, cuda)')
    parser.add_argument('--size', type=int, default=384, help='Video size (384 balanced for TikTok/Instagram)')

    args = parser.parse_args()

    # Create namespace object for SadTalker
    class SadTalkerArgs:
        pass

    sadtalker_args = SadTalkerArgs()
    sadtalker_args.driven_audio = args.audio
    sadtalker_args.source_image = args.image
    sadtalker_args.result_dir = str(Path(args.output).parent)
    sadtalker_args.checkpoint_dir = args.checkpoint_dir
    sadtalker_args.device = args.device
    sadtalker_args.enhancer = None
    sadtalker_args.background_enhancer = None
    sadtalker_args.still = True
    sadtalker_args.preprocess = 'crop'
    sadtalker_args.size = args.size
    sadtalker_args.expression_scale = 1.0
    sadtalker_args.pose_style = 0
    sadtalker_args.batch_size = 1  # Reduced for M3 Mac stability
    sadtalker_args.input_yaw = None
    sadtalker_args.input_pitch = None
    sadtalker_args.input_roll = None
    sadtalker_args.ref_eyeblink = None
    sadtalker_args.ref_pose = None
    sadtalker_args.face3dvis = False
    sadtalker_args.verbose = False
    # Additional renderer parameters
    sadtalker_args.net_recon = 'resnet50'
    sadtalker_args.init_path = None
    sadtalker_args.use_last_fc = False
    sadtalker_args.bfm_folder = './checkpoints/BFM_Fitting/'
    sadtalker_args.bfm_model = 'BFM_model_front.mat'
    sadtalker_args.focal = 1015.
    sadtalker_args.center = 112.
    sadtalker_args.camera_d = 10.
    sadtalker_args.z_near = 5.
    sadtalker_args.z_far = 15.
    sadtalker_args.old_version = False

    # Change to SadTalker directory for correct path resolution
    original_cwd = os.getcwd()
    os.chdir(SADTALKER_DIR)

    # Run SadTalker
    try:
        sadtalker_inference(sadtalker_args)
        print(f"✅ Video generated successfully: {args.output}")
    except Exception as e:
        print(f"❌ Error during inference: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)
    finally:
        os.chdir(original_cwd)

if __name__ == '__main__':
    main()
