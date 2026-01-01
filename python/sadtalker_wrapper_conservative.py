#!/usr/bin/env python3
"""
Conservative wrapper for SadTalker inference with memory optimization.
Use this if regular wrapper crashes during rendering.
"""
import sys
import os
import gc
import torch
from pathlib import Path
from argparse import ArgumentParser

# Add SadTalker directory to Python path
SADTALKER_DIR = Path(__file__).parent.parent / "sadtalker"
sys.path.insert(0, str(SADTALKER_DIR))

# CRITICAL: Set sys.argv[0] to point to inference.py in sadtalker directory
sys.argv[0] = str(SADTALKER_DIR / "inference.py")

# Import SadTalker's main function
from inference import main as sadtalker_inference

def main():
    """Parse arguments and call SadTalker inference with conservative settings"""
    parser = ArgumentParser(description='SadTalker wrapper (memory-optimized)')
    parser.add_argument('--image', required=True, help='Path to source image')
    parser.add_argument('--audio', required=True, help='Path to audio file')
    parser.add_argument('--output', required=True, help='Path for output video')
    parser.add_argument('--checkpoint-dir', required=True, help='Path to checkpoints directory')
    parser.add_argument('--device', default='cpu', help='Device to use (cpu, mps, cuda)')
    parser.add_argument('--size', type=int, default=384, help='Video size (use 256 for extreme memory constraints)')

    args = parser.parse_args()

    # Force garbage collection and clear CUDA cache before starting
    gc.collect()
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
        print(f"🎮 CUDA Device: {torch.cuda.get_device_name(0)}")
        print(f"💾 VRAM Available: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.2f} GB")

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

    # CRITICAL: Reduce batch_size to prevent OOM during rendering
    # batch_size=1 processes 1 frame at a time (slower but safer)
    sadtalker_args.batch_size = 1

    sadtalker_args.input_yaw = None
    sadtalker_args.input_pitch = None
    sadtalker_args.input_roll = None
    sadtalker_args.ref_eyeblink = None
    sadtalker_args.ref_pose = None
    sadtalker_args.face3dvis = False
    sadtalker_args.verbose = True  # Enable verbose for debugging

    # Renderer parameters
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

    print(f"⚙️  Memory-optimized settings:")
    print(f"   - Size: {args.size}x{args.size}")
    print(f"   - Batch size: 1 (safest)")
    print(f"   - Device: {args.device}")

    # Run SadTalker
    try:
        sadtalker_inference(sadtalker_args)
        print(f"✅ Video generated successfully: {args.output}")
    except RuntimeError as e:
        if "out of memory" in str(e).lower() or "cuda" in str(e).lower():
            print(f"❌ GPU Memory Error: {e}", file=sys.stderr)
            print("\n💡 Suggestions:", file=sys.stderr)
            print("   1. Reduce video size: --size 256", file=sys.stderr)
            print("   2. Use shorter audio clips", file=sys.stderr)
            print("   3. Check nvidia-smi for memory usage", file=sys.stderr)
            if torch.cuda.is_available():
                print(f"\n📊 VRAM Usage:", file=sys.stderr)
                print(f"   Allocated: {torch.cuda.memory_allocated() / 1024**3:.2f} GB", file=sys.stderr)
                print(f"   Reserved: {torch.cuda.memory_reserved() / 1024**3:.2f} GB", file=sys.stderr)
        else:
            print(f"❌ Runtime Error: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error during inference: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)
    finally:
        os.chdir(original_cwd)
        # Cleanup
        gc.collect()
        if torch.cuda.is_available():
            torch.cuda.empty_cache()

if __name__ == '__main__':
    main()
