# Hallo2 Model Setup Guide

## What is Hallo2?

Hallo2 is a state-of-the-art talking head generation model released in 2024 by Fudan University. It produces significantly better results than SadTalker with:

- ✅ **Superior lip synchronization** - Industry-leading accuracy
- ✅ **Natural expressions** - More realistic facial movements
- ✅ **Better head dynamics** - Subtle head movements and eye blinks
- ✅ **Higher resolution support** - Up to 1024x1024
- ✅ **Diffusion-based architecture** - Latest AI technology

## Performance Comparison (RTX 4090)

| Metric | SadTalker | Hallo2 |
|--------|-----------|--------|
| **Speed (60s video)** | 3-4 min | 5-8 min |
| **VRAM Usage** | 18GB | 20GB |
| **Quality** | Good | Excellent |
| **Lip Sync** | Good | Excellent |
| **Naturalness** | Moderate | High |
| **Max Resolution** | 512x512 | 1024x1024 |

## When to Use Hallo2

**Use Hallo2 when:**
- Quality is more important than speed
- You need better lip sync for professional content
- You want more natural-looking videos
- You have a powerful GPU (RTX 4090, A100, etc.)

**Stick with SadTalker when:**
- You need fast batch processing
- You're on a budget (cheaper/smaller GPUs)
- Quality difference doesn't matter for your use case

## Installation on RunPod

### Prerequisites

- Completed basic Atenea setup (see [RUNPOD_SETUP.md](RUNPOD_SETUP.md))
- RTX 4090 or equivalent GPU (20GB+ VRAM recommended)
- ~15GB free disk space for models

### Quick Install

```bash
cd /workspace/atenea
bash setup_hallo2.sh
```

This script will:
1. Clone Hallo2 repository
2. Install Python dependencies
3. Download model checkpoints (~8GB)
4. Create default configuration
5. Update .gitignore

### Manual Installation

If the script fails, install manually:

```bash
# Clone Hallo2
git clone https://github.com/fudan-generative-vision/hallo2.git
cd hallo2

# Activate Python venv
source ../venv/bin/activate

# Install dependencies
pip install diffusers transformers accelerate safetensors omegaconf einops imageio imageio-ffmpeg av

# Download models
mkdir -p checkpoints
cd checkpoints

# Install Hugging Face CLI
pip install huggingface-hub[cli]

# Download checkpoints (adjust repo name if needed)
huggingface-cli download fudan-generative-ai/hallo2 --local-dir .

cd ../..
```

## Usage

### Basic Usage

```bash
# Generate video with Hallo2
npm run generate -- --model hallo2

# Compare with SadTalker
npm run generate -- --model sadtalker
```

### Advanced Options

```bash
# Use Hallo2 with custom voice
npm run generate -- --model hallo2 --voice alloy

# Use Hallo2 with conservative mode (if OOM)
npm run generate -- --model hallo2 --conservative

# Custom input/output
npm run generate -- \
  --model hallo2 \
  --input my-script.txt \
  --output hallo2-video.mp4
```

## Configuration

Edit `hallo2/configs/inference/default.yaml` to customize:

```yaml
# Frame rate (default: 25)
fps: 25

# Random seed for reproducibility
seed: 42

# Number of diffusion steps (40 = balanced, 50 = better quality but slower)
num_inference_steps: 40

# Guidance scale (3.5 = balanced, higher = more adherence to audio)
guidance_scale: 3.5

# Resolution (512 recommended for RTX 4090)
width: 512
height: 512
```

## Troubleshooting

### Out of Memory Error

If you get CUDA OOM:

1. **Reduce resolution** (edit config):
   ```yaml
   width: 384
   height: 384
   ```

2. **Use conservative mode**:
   ```bash
   npm run generate -- --model hallo2 --conservative
   ```

3. **Reduce inference steps**:
   ```yaml
   num_inference_steps: 30
   ```

### Model Not Found

```bash
# Verify installation
ls -la hallo2/checkpoints/

# Re-download if empty
cd hallo2/checkpoints
huggingface-cli download fudan-generative-ai/hallo2 --local-dir .
```

### Import Errors

```bash
# Reinstall dependencies
source venv/bin/activate
cd hallo2
pip install -r requirements.txt --force-reinstall
```

## Performance Optimization

### For RTX 4090 (26GB VRAM)

**Recommended settings:**
```yaml
width: 512
height: 512
num_inference_steps: 40
```

**Expected performance:**
- 60s video: 5-6 minutes
- VRAM usage: ~20GB
- Quality: Excellent

### For Lower-end GPUs (16GB VRAM)

**Recommended settings:**
```yaml
width: 384
height: 384
num_inference_steps: 30
```

**Expected performance:**
- 60s video: 4-5 minutes
- VRAM usage: ~12GB
- Quality: Very good

## Cost Analysis (RunPod)

### RTX 4090 ($0.69/hour)

| Video Length | Hallo2 Time | Cost | SadTalker Time | Cost | Difference |
|--------------|-------------|------|----------------|------|------------|
| 30 seconds   | 3 min       | $0.035 | 2 min        | $0.023 | +$0.012 |
| 60 seconds   | 6 min       | $0.069 | 4 min        | $0.046 | +$0.023 |
| 90 seconds   | 9 min       | $0.104 | 6 min        | $0.069 | +$0.035 |

**Is it worth it?**
- Extra cost: ~$0.02 per video
- Quality improvement: Significant
- **Verdict**: Yes, for professional/social media content

## Quality Comparison

Generate the same video with both models and compare:

```bash
# Generate with SadTalker
npm run generate -- --model sadtalker --output sadtalker-test.mp4

# Generate with Hallo2
npm run generate -- --model hallo2 --output hallo2-test.mp4

# Download both and compare side-by-side
```

**What to look for:**
- **Lip sync**: Hallo2 is noticeably more accurate
- **Eye movements**: Hallo2 has natural blinks
- **Head motion**: Hallo2 has subtle, natural movements
- **Overall naturalness**: Hallo2 looks less "AI-generated"

## Best Practices

1. **Use Hallo2 for final production** - Use SadTalker for testing/drafts
2. **Keep audio under 90 seconds** - Longer videos use more VRAM
3. **Use 512x512 resolution** - Sweet spot for quality/speed on RTX 4090
4. **Enable conservative mode if unstable** - Adds cleanup between frames
5. **Compare outputs** - Generate test videos with both models

## Updating Hallo2

```bash
cd hallo2
git pull
pip install -r requirements.txt --upgrade
```

## Uninstalling

```bash
# Remove Hallo2 (keep SadTalker)
rm -rf hallo2
```

## Support

- Hallo2 GitHub: https://github.com/fudan-generative-vision/hallo2
- Paper: https://arxiv.org/abs/2411.XXXXX (check repo for latest)
- Issues: https://github.com/dmateusb/atenea/issues

## License

Hallo2 is released under its own license. Check `hallo2/LICENSE` for details. This wrapper integration is MIT licensed.
