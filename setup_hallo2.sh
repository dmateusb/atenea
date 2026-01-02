#!/bin/bash
# Setup script for Hallo2 model
# Run this on RunPod after completing basic setup

set -e

echo "🚀 Setting up Hallo2 Model"
echo "This will download ~8GB of model weights"
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: Run this script from the atenea project root"
    exit 1
fi

# Clone Hallo2 repository
if [ -d "hallo2" ]; then
    echo "⚠️  Hallo2 directory already exists"
    read -p "Remove and re-clone? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf hallo2
    else
        echo "Skipping clone"
    fi
fi

if [ ! -d "hallo2" ]; then
    echo "1️⃣  Cloning Hallo2 repository..."
    git clone https://github.com/fudan-generative-vision/hallo2.git
    echo "   ✅ Hallo2 cloned"
fi

# Install Hallo2 dependencies
echo "2️⃣  Installing Hallo2 Python dependencies..."
cd hallo2

# Activate venv if exists
if [ -f "../venv/bin/activate" ]; then
    source ../venv/bin/activate
fi

# Install requirements
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt --quiet
    echo "   ✅ Dependencies installed"
else
    echo "   ⚠️  No requirements.txt found, installing common dependencies..."
    pip install --quiet \
        diffusers \
        transformers \
        accelerate \
        safetensors \
        omegaconf \
        einops \
        imageio \
        imageio-ffmpeg \
        av
fi

cd ..

# Download model checkpoints
echo "3️⃣  Downloading Hallo2 model checkpoints..."
mkdir -p hallo2/checkpoints

# Check if checkpoints exist
if [ -d "hallo2/checkpoints" ] && [ "$(ls -A hallo2/checkpoints 2>/dev/null)" ]; then
    echo "   ✅ Checkpoints already exist"
else
    echo "   📥 This will download ~8GB of data..."

    # Try using huggingface-cli if available
    if command -v huggingface-cli &> /dev/null; then
        echo "   Using huggingface-cli..."
        cd hallo2/checkpoints
        huggingface-cli download fudan-generative-ai/hallo2 --local-dir .
        cd ../..
    else
        echo "   Installing huggingface-cli..."
        pip install --quiet huggingface-hub[cli]
        cd hallo2/checkpoints
        huggingface-cli download fudan-generative-ai/hallo2 --local-dir .
        cd ../..
    fi

    echo "   ✅ Checkpoints downloaded"
fi

# Create default config if needed
echo "4️⃣  Setting up configuration..."
mkdir -p hallo2/configs/inference

if [ ! -f "hallo2/configs/inference/default.yaml" ]; then
    cat > hallo2/configs/inference/default.yaml << 'EOF'
# Hallo2 Inference Configuration
fps: 25
seed: 42
num_inference_steps: 40
guidance_scale: 3.5
width: 512
height: 512
EOF
    echo "   ✅ Default config created"
else
    echo "   ✅ Config already exists"
fi

# Update .gitignore to exclude Hallo2
if ! grep -q "^hallo2/" .gitignore 2>/dev/null; then
    echo "" >> .gitignore
    echo "# Hallo2 (external repository)" >> .gitignore
    echo "hallo2/" >> .gitignore
    echo "   ✅ Updated .gitignore"
fi

echo ""
echo "✅ Hallo2 setup complete!"
echo ""
echo "📝 Test Hallo2:"
echo "   npm run generate -- --model hallo2"
echo ""
echo "📊 Disk space used:"
du -sh hallo2 2>/dev/null || echo "   (unable to calculate)"
echo ""
echo "💡 Performance (RTX 4090):"
echo "   - Speed: 5-8 minutes for 60s video"
echo "   - VRAM: ~20GB at 512x512"
echo "   - Quality: Significantly better than SadTalker"
echo ""
