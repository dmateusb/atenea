#!/usr/bin/env python3
"""
Wrapper script for Hallo2 inference.
Hallo2 is a state-of-the-art talking head generation model with superior lip sync and expression.
"""
import sys
import os
import gc
import torch
from pathlib import Path
from argparse import ArgumentParser

# Hallo2 directory
HALLO2_DIR = Path(__file__).parent.parent / "hallo2"
sys.path.insert(0, str(HALLO2_DIR))

def main():
    """Parse arguments and call Hallo2 inference"""
    parser = ArgumentParser(description='Hallo2 wrapper for video generation')
    parser.add_argument('--image', required=True, help='Path to source image')
    parser.add_argument('--audio', required=True, help='Path to audio file')
    parser.add_argument('--output', required=True, help='Path for output video')
    parser.add_argument('--checkpoint-dir', required=True, help='Path to checkpoints directory')
    parser.add_argument('--device', default='cpu', help='Device to use (cpu, cuda)')
    parser.add_argument('--size', type=int, default=512, help='Video size (512 or 1024)')

    args = parser.parse_args()

    # Force garbage collection and clear CUDA cache before starting
    gc.collect()
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
        print(f"🎮 CUDA Device: {torch.cuda.get_device_name(0)}")
        print(f"💾 VRAM Available: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.2f} GB")

    # Validate inputs
    if not os.path.exists(args.image):
        print(f"❌ Image not found: {args.image}", file=sys.stderr)
        sys.exit(1)

    if not os.path.exists(args.audio):
        print(f"❌ Audio not found: {args.audio}", file=sys.stderr)
        sys.exit(1)

    # Validate checkpoint directory
    if not os.path.exists(args.checkpoint_dir):
        print(f"❌ Checkpoint directory not found: {args.checkpoint_dir}", file=sys.stderr)
        print("Run: bash download_hallo2_models.sh", file=sys.stderr)
        sys.exit(1)

    print(f"🎬 Hallo2 Video Generation")
    print(f"📐 Resolution: {args.size}x{args.size}")
    print(f"📸 Source Image: {args.image}")
    print(f"🎵 Audio: {args.audio}")
    print(f"🎥 Output: {args.output}")
    print(f"⚙️  Device: {args.device}")

    # Change to Hallo2 directory
    original_cwd = os.getcwd()
    os.chdir(HALLO2_DIR)

    try:
        # Import Hallo2 modules
        from scripts.inference import inference as hallo2_inference
        from omegaconf import OmegaConf

        # Load config
        config_path = HALLO2_DIR / "configs" / "inference" / "default.yaml"
        if not config_path.exists():
            # Create default config if not exists
            config = OmegaConf.create({
                'source_image': args.image,
                'driving_audio': args.audio,
                'output': args.output,
                'checkpoint_dir': args.checkpoint_dir,
                'device': args.device,
                'width': args.size,
                'height': args.size,
                'fps': 25,
                'seed': 42,
                'num_inference_steps': 40,
                'guidance_scale': 3.5,
            })
        else:
            config = OmegaConf.load(config_path)
            # Override with command line arguments
            config.source_image = args.image
            config.driving_audio = args.audio
            config.output = args.output
            config.checkpoint_dir = args.checkpoint_dir
            config.device = args.device
            config.width = args.size
            config.height = args.size

        # Run Hallo2 inference
        print(f"\n🚀 Starting Hallo2 inference...")
        hallo2_inference(config)

        print(f"\n✅ Video generated successfully: {args.output}")
        return 0

    except ImportError as e:
        print(f"❌ Hallo2 not installed properly: {e}", file=sys.stderr)
        print("\nPlease run:", file=sys.stderr)
        print("  cd /workspace/atenea", file=sys.stderr)
        print("  bash setup_hallo2.sh", file=sys.stderr)
        return 1

    except RuntimeError as e:
        if "out of memory" in str(e).lower() or "cuda" in str(e).lower():
            print(f"❌ GPU Memory Error: {e}", file=sys.stderr)
            print("\n💡 Suggestions:", file=sys.stderr)
            print("   1. Use --size 512 instead of 1024", file=sys.stderr)
            print("   2. Use shorter audio clips", file=sys.stderr)
            if torch.cuda.is_available():
                print(f"\n📊 VRAM Usage:", file=sys.stderr)
                print(f"   Allocated: {torch.cuda.memory_allocated() / 1024**3:.2f} GB", file=sys.stderr)
                print(f"   Reserved: {torch.cuda.memory_reserved() / 1024**3:.2f} GB", file=sys.stderr)
        else:
            print(f"❌ Runtime Error: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return 1

    except Exception as e:
        print(f"❌ Error during inference: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return 1

    finally:
        os.chdir(original_cwd)
        # Cleanup
        gc.collect()
        if torch.cuda.is_available():
            torch.cuda.empty_cache()

if __name__ == '__main__':
    sys.exit(main())
