# Quick Setup Guide for Atenea

## Step-by-Step Installation

### 1. Run the setup script

```bash
chmod +x setup.sh
./setup.sh
```

**What this does:**

- Creates Python virtual environment
- Installs PyTorch with Metal (MPS) support for M3
- Clones SadTalker repository
- Downloads model checkpoints (~2-3GB, may take 10-15 minutes)
- Installs Node.js dependencies

**Estimated time**: 15-30 minutes (depending on internet speed)

### 2. Add your OpenAI API key

```bash
cp .env.example .env
```

Then edit `.env` and add your key:

```
OPENAI_API_KEY=sk-your-actual-key-here
TTS_VOICE=nova
```

### 3. Add an avatar image

Place a photo of a woman at `data/images/avatar.png`

**Requirements:**

- Clear, front-facing photo
- Good lighting
- Neutral expression recommended
- PNG or JPG format
- At least 512×512 pixels

### 4. Test with the sample input

The project includes a sample `input.txt`. Try generating your first video:

```bash
npm run dev -- generate
```

This will create `output.mp4` with the sample text.

## Daily Usage

### Generate video from your text

1. Edit `input.txt` with your script
2. Run: `npm run dev -- generate`
3. Wait 8-15 minutes for 1-minute video
4. Find your video at `output.mp4`

### Custom options

```bash
# Use different input file
npm run dev -- generate --input my-script.txt

# Save to specific location
npm run dev -- generate --output videos/presentation.mp4

# Use different voice
npm run dev -- generate --voice shimmer

# Use different avatar
npm run dev -- generate --avatar photos/host2.png
```

## Troubleshooting

### Setup script fails

- Ensure Python 3.10+ is installed: `python3 --version`
- Check internet connection for downloading models
- Ensure you have ~5GB free disk space

### "OPENAI_API_KEY not found"

- Create `.env` file (not `.env.example`)
- Add your actual API key from https://platform.openai.com

### "Avatar image not found"

- Create directory: `mkdir -p data/images`
- Add your image: `cp your-photo.png data/images/avatar.png`

### Generation is very slow

- Expected! M3 16GB takes 8-15 minutes for 1-minute video
- Close other applications to free up RAM
- Consider cloud GPU for batch processing (see main README)

## Next Steps

Once everything works:

1. Create your own avatar images for different scenarios
2. Experiment with different TTS voices
3. Batch generate multiple videos
4. Read the full [README.md](README.md) for advanced usage

## Quick Reference

| Command                          | Description                   |
| -------------------------------- | ----------------------------- |
| `npm run dev -- generate`        | Generate video from input.txt |
| `npm run dev -- generate --help` | Show all available options    |
| `npm run typecheck`              | Check TypeScript types        |
| `npm run lint`                   | Run linter                    |
| `npm run format`                 | Format code with Prettier     |

## Performance Expectations

| Video Length | Generation Time (M3 16GB) | Cost (OpenAI TTS) |
| ------------ | ------------------------- | ----------------- |
| 30 seconds   | ~4-7 minutes              | ~$0.007           |
| 1 minute     | ~8-15 minutes             | ~$0.015           |
| 2 minutes    | ~16-30 minutes            | ~$0.030           |

Happy video generating! 🎬
