#!/bin/bash
# Quick dependency installer for RunPod
# Run this after cloning the repo for the first time

set -e

echo "🚀 Installing RunPod dependencies..."
echo ""

# Update package list
echo "1️⃣  Updating package list..."
apt-get update -qq

# Install FFmpeg (required for video/audio processing)
echo "2️⃣  Installing FFmpeg..."
apt-get install -y ffmpeg > /dev/null 2>&1
echo "   ✅ FFmpeg installed: $(ffmpeg -version | head -n1)"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "3️⃣  Installing Node.js 20..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - > /dev/null 2>&1
    apt-get install -y nodejs > /dev/null 2>&1
    echo "   ✅ Node.js installed: $(node --version)"
else
    echo "3️⃣  Node.js already installed: $(node --version)"
fi

# Install npm dependencies
echo "4️⃣  Installing npm packages..."
npm install --silent
echo "   ✅ npm dependencies installed"

# Create Python virtual environment
if [ ! -d "venv" ]; then
    echo "5️⃣  Creating Python virtual environment..."
    python3 -m venv venv
    echo "   ✅ Virtual environment created"
else
    echo "5️⃣  Virtual environment already exists"
fi

# Activate venv and install Python dependencies
echo "6️⃣  Installing Python dependencies..."
source venv/bin/activate
pip install --upgrade pip --quiet
pip install -r requirements.txt --quiet
echo "   ✅ Python dependencies installed"

# Clone SadTalker if not present
if [ ! -d "sadtalker" ]; then
    echo "7️⃣  Cloning SadTalker repository..."
    git clone https://github.com/OpenTalker/SadTalker.git sadtalker --quiet
    echo "   ✅ SadTalker cloned"
else
    echo "7️⃣  SadTalker already cloned"
fi

# Apply NumPy fixes
echo "8️⃣  Applying NumPy 2.x compatibility fixes..."
chmod +x fix_sadtalker_numpy2.sh
./fix_sadtalker_numpy2.sh
echo "   ✅ NumPy fixes applied"

# Download models
if [ ! -d "sadtalker/checkpoints" ] || [ -z "$(ls -A sadtalker/checkpoints 2>/dev/null)" ]; then
    echo "9️⃣  Downloading SadTalker models (~3GB, may take 5-10 minutes)..."
    chmod +x download_models.sh
    ./download_models.sh
    echo "   ✅ Models downloaded"
else
    echo "9️⃣  Models already downloaded"
fi

echo ""
echo "✅ All dependencies installed successfully!"
echo ""
echo "📝 Next steps:"
echo "   1. Create .env file with your OpenAI API key:"
echo "      echo \"OPENAI_API_KEY='your-key-here'\" > .env"
echo ""
echo "   2. Add your avatar image:"
echo "      mkdir -p data/images"
echo "      # Upload your image to data/images/avatar.png"
echo ""
echo "   3. Create input text:"
echo "      echo \"Hello, this is my first AI video!\" > input.txt"
echo ""
echo "   4. Generate video:"
echo "      npm run generate"
echo ""
echo "💡 Pro tip: Use screen to keep session alive:"
echo "   screen -S atenea"
echo "   npm run generate"
echo "   # Press Ctrl+A, then D to detach"
echo ""
