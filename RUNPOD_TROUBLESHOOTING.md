# RunPod Troubleshooting Guide

## Issue: FFmpeg/ffprobe Not Found

If you get `FileNotFoundError: [Errno 2] No such file or directory: 'ffprobe'`:

```bash
# Install FFmpeg (includes ffprobe and ffmpeg)
apt-get update && apt-get install -y ffmpeg

# Verify installation
ffmpeg -version
ffprobe -version

# Re-run generation
npm run generate
```

This error occurs at the final step when combining rendered frames with audio. The rendering was successful, just needs FFmpeg to finalize.

---

## Issue: Process Crashes at 45% (897/2000 frames)

If your video generation consistently stops at the same point during rendering, follow these steps:

### Step 1: Check the Real Error Message

The crash is likely a **CUDA Out of Memory (OOM)** error that's being hidden. Run this to see the actual error:

```bash
cd /workspace/atenea
npm run generate 2>&1 | tee generation.log
```

Look for errors like:
- `RuntimeError: CUDA out of memory`
- `torch.cuda.OutOfMemoryError`
- `Killed` (OOM killer terminated the process)

### Step 2: Monitor GPU Memory During Generation

Open a second terminal and run:

```bash
watch -n 1 nvidia-smi
```

Watch the memory usage:
- **GPU Memory**: Should stay below 24GB on RTX 4090
- **Power Draw**: Should be 200-400W during rendering
- If memory hits 100%, reduce resolution

### Step 3: Try Lower Resolution

Edit `python/generate_video.py` and change line 21:

```python
# FROM:
return device, 512  # High quality for GPU

# TO:
return device, 384  # Safer for memory
```

Or manually override in the wrapper:

```bash
# Edit python/sadtalker_wrapper.py line 48
sadtalker_args.size = 384  # Instead of args.size
```

### Step 4: Use Conservative Wrapper (Emergency Option)

If still crashing, use the memory-optimized wrapper. You have three options:

**Option A: CLI flag (easiest)**
```bash
npm run generate -- --conservative
```

**Option B: Environment variable**
```bash
USE_CONSERVATIVE=1 npm run generate
```

**Option C: Manual swap**
```bash
cd /workspace/atenea
cp python/sadtalker_wrapper.py python/sadtalker_wrapper_backup.py
cp python/sadtalker_wrapper_conservative.py python/sadtalker_wrapper.py
npm run generate
```

The conservative wrapper adds:
- Explicit garbage collection before/after rendering
- CUDA cache clearing
- Better error messages with memory diagnostics
- Real-time VRAM usage reporting

### Step 5: Reduce Audio Length

Long audio = more frames = more memory:

- **30 seconds**: ~600 frames (safest)
- **60 seconds**: ~1500 frames (recommended)
- **90 seconds**: ~2250 frames (may OOM at 512x512)
- **120+ seconds**: Split into multiple videos

### Step 6: Check System Logs

If process is being killed by system:

```bash
dmesg | tail -50 | grep -i "killed\|oom"
```

If you see OOM killer messages, you need to:
1. Reduce resolution (384 or 256)
2. Reduce audio length
3. Check for other processes using memory

## Expected Performance (RTX 4090)

| Resolution | Speed       | VRAM Usage | Time (60s audio) |
|------------|-------------|------------|------------------|
| 256x256    | 12-15 it/s  | ~8 GB      | ~2 minutes       |
| 384x384    | 10-12 it/s  | ~12 GB     | ~2.5 minutes     |
| 512x512    | 8-10 it/s   | ~18 GB     | ~3-4 minutes     |
| 768x768    | 4-6 it/s    | ~24 GB     | ~8-10 minutes    |

If you're getting 8.6 it/s at 512x512 but crashing at 45%, this suggests:
- Memory leak accumulating during rendering
- VRAM usage growing beyond 26GB limit
- **Solution**: Use 384x384 resolution

## Running in Persistent Session

To survive SSH disconnections:

```bash
# Start screen session
screen -S atenea

# Run generation
cd /workspace/atenea
npm run generate 2>&1 | tee generation.log

# Detach: Ctrl+A, then D

# Reattach later
screen -r atenea
```

## Checking if Video Completed

After disconnection:

```bash
# Check for output
ls -lh /workspace/atenea/output.mp4

# Check screen sessions
screen -ls

# View logs
tail -100 /workspace/atenea/generation.log
```

## Quick Fixes Summary

**For OOM crashes at 45%:**
1. ✅ Reduce resolution to 384x384
2. ✅ Use shorter audio (30-60 seconds)
3. ✅ Monitor with `nvidia-smi`
4. ✅ Use screen for persistence

**For debugging:**
```bash
# Run with full logging
bash debug_generation.sh

# Check the log
cat /workspace/atenea/debug_*.log
```

**For emergency recovery:**
```bash
# Use conservative wrapper
cp python/sadtalker_wrapper_conservative.py python/sadtalker_wrapper.py

# Try minimal resolution
# Edit generate_video.py line 21: return device, 256
```

## Still Having Issues?

### Check System Dependencies

```bash
# Check GPU
nvidia-smi

# Check PyTorch CUDA
python3 -c "import torch; print(torch.cuda.is_available())"

# Check FFmpeg
which ffmpeg ffprobe
ffmpeg -version

# Check RAM
free -h

# Check disk space
df -h

# Check Node.js
node --version
npm --version
```

### Common Missing Dependencies

```bash
# If FFmpeg is missing
apt-get update && apt-get install -y ffmpeg

# If Node.js is missing
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# If Python venv is not activated
source venv/bin/activate
```

### Run Full Diagnostic

```bash
bash debug_generation.sh
cat /workspace/atenea/debug_*.log
```
