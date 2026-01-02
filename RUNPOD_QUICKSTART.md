# RunPod Quick Start Guide

## First Time Setup

### Quick Install (Recommended)

```bash
# SSH into RunPod
ssh root@<your-pod-ip> -p <port>

# Clone repository
cd /workspace
git clone https://github.com/<your-username>/atenea.git
cd atenea

# Run automated setup (installs everything)
bash install_runpod_deps.sh

# Create .env file
echo "OPENAI_API_KEY='your-key-here'" > .env

# Add your avatar image
mkdir -p data/images
# Upload your image to data/images/avatar.png

# Create input text
echo "Hello, this is my first AI video!" > input.txt
```

### Manual Install (Alternative)

```bash
# Install system dependencies
apt-get update && apt-get install -y ffmpeg

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Install npm dependencies
npm install

# Setup Python environment
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Clone and setup SadTalker
git clone https://github.com/OpenTalker/SadTalker.git sadtalker
bash fix_sadtalker_numpy2.sh
bash download_models.sh

# Configure environment
echo "OPENAI_API_KEY='your-key-here'" > .env
```

## Running Video Generation

### Basic Usage (SadTalker)

```bash
# Create input text
echo "Hello, this is my first AI video!" > input.txt

# Generate video (default: SadTalker)
npm run generate

# Or explicitly specify model
npm run generate -- --model sadtalker
```

### Using Hallo2 (Better Quality)

First install Hallo2 (one-time setup):
```bash
bash setup_hallo2.sh
```

Then generate:
```bash
# Generate with Hallo2 (slower but better quality)
npm run generate -- --model hallo2
```

See [HALLO2_SETUP.md](HALLO2_SETUP.md) for details.

### With Conservative Mode (Recommended for First Run)

```bash
# SadTalker with conservative mode
npm run generate -- --conservative

# Hallo2 with conservative mode
npm run generate -- --model hallo2 --conservative
```

### In Persistent Session (Recommended)

```bash
# Start screen session
screen -S atenea

# Generate video with logging
npm run generate -- --conservative 2>&1 | tee generation.log

# Detach: Press Ctrl+A, then D

# Later: Reattach
screen -r atenea
```

## Quick Commands

```bash
# Check GPU status
nvidia-smi

# Check if video completed
ls -lh output.mp4

# View generation logs
tail -f generation.log

# Monitor GPU in real-time
watch -n 1 nvidia-smi

# Apply crash fix (reduces to 384x384)
bash fix_crash.sh

# Debug with full logs
bash debug_generation.sh
```

## Common Issues

### Crash at 45%
```bash
# Pull latest fixes
git pull

# Run with conservative mode
npm run generate -- --conservative
```

### Out of Memory
```bash
# Reduce resolution
bash fix_crash.sh
npm run generate -- --conservative
```

### Session Disconnected
```bash
# Always use screen
screen -S atenea
npm run generate -- --conservative 2>&1 | tee generation.log
# Ctrl+A, D to detach
```

## Custom Options

```bash
# Different voice
npm run generate -- --voice alloy

# Different model
npm run generate -- --model hallo2

# Different input file
npm run generate -- --input my-script.txt

# Different output
npm run generate -- --output my-video.mp4

# Combine options
npm run generate -- \
  --model hallo2 \
  --voice nova \
  --conservative \
  --output result.mp4
```

## Performance Reference (RTX 4090)

| Mode          | Resolution | Time (60s audio) | VRAM Usage |
|---------------|------------|------------------|------------|
| Default       | 512x512    | ~4 minutes       | ~18 GB     |
| Conservative  | 384x384    | ~3 minutes       | ~12 GB     |

## Cost Estimate

- RTX 4090: $0.69/hour
- 3-minute video generation: ~$0.035 (3.5 cents)
- 1 hour = ~20 videos

## Downloading Your Video

```bash
# From your local machine
scp -P <port> root@<pod-ip>:/workspace/atenea/output.mp4 ~/Downloads/
```

## Stopping the Pod

```bash
# Check for running processes
screen -ls
ps aux | grep npm

# Kill if needed
screen -X -S atenea quit

# Then stop pod from RunPod web interface
```

## Help

- Full troubleshooting: `cat RUNPOD_TROUBLESHOOTING.md`
- Setup details: `cat RUNPOD_SETUP.md`
- All options: `npm run generate -- --help`
