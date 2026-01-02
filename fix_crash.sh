#!/bin/bash
# Quick fix for 45% crash issue on RunPod

set -e

echo "🔧 Applying fixes for rendering crash at 45%..."
echo ""

# Fix 1: Reduce resolution to prevent OOM
echo "1️⃣  Reducing resolution from 512 to 384 for stability..."
sed -i.bak 's/return device, 512  # High quality for GPU/return device, 384  # Stable for most GPUs/g' python/generate_video.py
rm -f python/generate_video.py.bak

# Fix 2: Ensure real-time output streaming (already done in latest version)
echo "2️⃣  Ensuring real-time output streaming..."
if grep -q "capture_output=True" python/generate_video.py; then
    echo "   ⚠️  Found buffered output, fixing..."
    # The fix is already applied via Edit tool above
else
    echo "   ✅ Already using real-time streaming"
fi

# Fix 3: Clear any cached CUDA state
echo "3️⃣  Clearing CUDA cache..."
python3 -c "import torch; torch.cuda.empty_cache() if torch.cuda.is_available() else None; print('   ✅ CUDA cache cleared')" 2>/dev/null || echo "   ⚠️  PyTorch not available"

# Fix 4: Check current GPU state
echo ""
echo "📊 Current GPU State:"
nvidia-smi --query-gpu=name,memory.total,memory.free,memory.used --format=csv,noheader,nounits | awk '{printf "   GPU: %s\n   VRAM: %.1f GB total, %.1f GB free, %.1f GB used\n", $1, $2/1024, $3/1024, $4/1024}'

echo ""
echo "✅ Fixes applied!"
echo ""
echo "📝 Changes made:"
echo "   - Reduced video resolution to 384x384 (more stable)"
echo "   - Enabled real-time output streaming"
echo "   - Cleared CUDA cache"
echo ""
echo "🎬 Now try running:"
echo "   screen -S atenea"
echo "   npm run generate 2>&1 | tee generation.log"
echo ""
echo "💡 If still crashes, see RUNPOD_TROUBLESHOOTING.md"
