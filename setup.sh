#!/bin/bash
set -e

echo "🚀 Setting up Atenea - AI Avatar Video Generator for M3 Mac"

# Check if Python 3.10+ is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.10-3.12."
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)

echo "✅ Found Python $PYTHON_VERSION"

# Check if Python version is 3.13+ (not yet fully compatible)
if [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 13 ]; then
    echo "⚠️  Warning: Python 3.13+ detected. Some packages may have compatibility issues."
    echo "   Recommended: Python 3.10, 3.11, or 3.12"
    echo "   Continuing anyway..."
fi

# Create virtual environment
if [ ! -d "venv" ]; then
    echo "📦 Creating Python virtual environment..."
    python3 -m venv venv
else
    echo "✅ Virtual environment already exists"
fi

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
echo "📦 Upgrading pip..."
pip install --upgrade pip

# Install PyTorch with MPS (Metal) support for M3
echo "📦 Installing PyTorch with Metal (MPS) support..."
pip install torch torchvision torchaudio

# Install other dependencies
echo "📦 Installing Python dependencies..."
pip install -r requirements.txt

# Clone SadTalker if not exists
if [ ! -d "sadtalker" ]; then
    echo "📥 Cloning SadTalker repository..."
    git clone https://github.com/OpenTalker/SadTalker.git sadtalker
    echo "⚠️  Skipping SadTalker's requirements.txt (not Python 3.13 compatible)"
    echo "   Using our custom requirements.txt instead"
else
    echo "✅ SadTalker already cloned"
fi

# Download SadTalker checkpoints
if [ ! -d "checkpoints" ]; then
    echo "📥 Downloading SadTalker model checkpoints..."
    mkdir -p checkpoints
    cd sadtalker
    bash scripts/download_models.sh
    cd ..
else
    echo "✅ Model checkpoints already downloaded"
fi

# Create necessary directories
mkdir -p data/images
mkdir -p data/audio
mkdir -p videos

# Install Node.js dependencies
echo "📦 Installing Node.js dependencies..."
npm install

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Add your OpenAI API key to .env file:"
echo "   echo 'OPENAI_API_KEY=your-key-here' > .env"
echo ""
echo "2. Add a female avatar image to data/images/avatar.png"
echo ""
echo "3. Create input.txt with your text content"
echo ""
echo "4. Run: npm run dev -- generate --input input.txt"
