# Atenea - AI Avatar Video Generator

Generate realistic talking head videos using AI. Simply provide text input, and Atenea will create a video of an avatar talking about the topic.

## Features

- 🎙️ **Text-to-speech** using OpenAI TTS (multiple voices)
- 🎬 **Multiple AI models**: SadTalker (fast) or Hallo2 (better quality)
- 🚀 **GPU acceleration**: Optimized for NVIDIA GPUs on RunPod
- 💻 **Simple CLI interface**: Easy to use command-line tool
- 📦 **Audio caching**: Avoid regenerating identical speech
- 🛡️ **Memory-optimized**: Conservative mode for stability

## Performance

### RunPod RTX 4090 (Recommended)

| Model | Time (60s video) | Quality | Cost |
|-------|------------------|---------|------|
| **SadTalker** | 3-4 minutes | Good | ~$0.05 |
| **Hallo2** | 5-8 minutes | Excellent | ~$0.07 |

### Local M3 Mac (16GB RAM)

| Model | Time (60s video) | Quality |
|-------|------------------|---------|
| **SadTalker** (CPU) | 8-15 minutes | Good |

**Recommendation**: Use RunPod GPU for faster, better results. See [RUNPOD_SETUP.md](RUNPOD_SETUP.md).

## Prerequisites

- macOS with M3 chip
- Python 3.10 or higher
- Node.js 20 or higher
- OpenAI API key
- Git

## Installation

### 1. Clone and setup

```bash
# Install dependencies and setup SadTalker
chmod +x setup.sh
./setup.sh
```

This will:

- Create Python virtual environment
- Install PyTorch with Metal (MPS) support
- Clone and setup SadTalker
- Download model checkpoints (~2-3GB)
- Install Node.js dependencies

### 2. Configure environment

```bash
# Create .env file with your OpenAI API key
cp .env.example .env
# Edit .env and add your API key
```

### 3. Add avatar image

Place a photo of a woman in `data/images/avatar.png`. This will be the face used in generated videos.

**Image requirements:**

- Clear, front-facing photo
- Good lighting
- Neutral background recommended
- PNG or JPG format
- Minimum 512×512 pixels

## Usage

### Generate a video

1. Create `input.txt` with your text content:

```txt
Welcome to today's discussion about artificial intelligence and its impact on modern society.
AI is transforming how we work, communicate, and solve complex problems.
```

2. Run the generator:

```bash
npm run dev -- generate
```

This will:

- Convert your text to speech using OpenAI TTS (nova voice)
- Generate a talking head video using SadTalker
- Save the result to `output.mp4`

### Advanced options

```bash
# Custom input file
npm run dev -- generate --input my-script.txt

# Custom output path
npm run dev -- generate --output videos/presentation.mp4

# Different voice (alloy, echo, fable, onyx, nova, shimmer)
npm run dev -- generate --voice alloy

# Custom avatar image
npm run dev -- generate --avatar photos/my-avatar.png
```

### Full example

```bash
npm run dev -- generate \
  --input scripts/intro.txt \
  --avatar images/host.png \
  --output videos/intro.mp4 \
  --voice shimmer
```

## Project Structure

```
atenea/
├── data/
│   ├── images/          # Avatar images
│   │   └── avatar.png   # Default avatar
│   └── audio/           # Generated audio files
├── videos/              # Generated videos
├── src/
│   ├── cli.ts           # CLI interface
│   ├── tts.ts           # Text-to-speech
│   ├── video-generator.ts  # Video generation
│   └── types.ts         # TypeScript types
├── python/
│   └── generate_video.py   # SadTalker wrapper
├── sadtalker/           # SadTalker repository (auto-cloned)
├── checkpoints/         # Model weights (auto-downloaded)
├── input.txt            # Your text input
└── output.mp4           # Generated video
```

## Configuration

### TTS Voices

Available OpenAI TTS voices:

- `nova` - Female, warm (default)
- `shimmer` - Female, expressive
- `alloy` - Gender-neutral, balanced
- `echo` - Male, calm
- `fable` - Male, storytelling
- `onyx` - Male, authoritative

Configure in `.env`:

```bash
TTS_VOICE=nova
TTS_MODEL=tts-1
```

### Video Generation

Default settings optimized for M3 16GB:

- Resolution: 512×512
- Batch size: 2
- Device: MPS (Metal)
- Enhancement: Disabled (for speed)

To modify, edit `python/generate_video.py`.

## Troubleshooting

### "MPS not available"

Ensure you're running on M3 Mac with macOS 13+ and PyTorch 2.0+.

### Out of memory

- Close other applications
- Reduce resolution in `generate_video.py`
- Use CPU instead of MPS (slower)

### Slow generation

Expected for M3 16GB. For faster processing:

- Lower resolution (256×256)
- Reduce frame rate
- Use cloud GPU (see `ai-avatar-generation-summary.md`)

### Poor video quality

- Use higher quality avatar image
- Ensure good lighting in avatar photo
- Try different voice/audio settings

## Cost Estimate

- **OpenAI TTS**: ~$0.015 per 1,000 characters
- **1-minute script (~1,000 chars)**: ~$0.015
- **Video generation**: Free (local processing)

**Total per video**: ~$0.01-0.02

Compare to:

- Google Veo: $0.20 per 8 seconds
- HeyGen/Synthesia: $0.10-0.30 per video

## Development

```bash
# Run in dev mode
npm run dev

# Build
npm run build

# Type check
npm run typecheck

# Lint
npm run lint

# Format
npm run format
```

## License

MIT

## Credits

- [SadTalker](https://github.com/OpenTalker/SadTalker) - Talking head generation
- OpenAI - Text-to-speech API
# atenea
# atenea
