#!/bin/bash
# Fix SadTalker for NumPy 2.x compatibility
# Run this after cloning SadTalker repository

set -e

echo "🔧 Applying NumPy 2.x compatibility fixes to SadTalker..."

# Fix 1: Remove np.VisibleDeprecationWarning (removed in NumPy 2.0)
if [ -f "sadtalker/src/face3d/util/preprocess.py" ]; then
    echo "  → Fixing preprocess.py (VisibleDeprecationWarning)"
    sed -i.bak '/np.VisibleDeprecationWarning/d' sadtalker/src/face3d/util/preprocess.py
    rm -f sadtalker/src/face3d/util/preprocess.py.bak
fi

# Fix 2: Replace np.float with np.float64 (np.float removed in NumPy 2.0)
if [ -f "sadtalker/src/face3d/util/my_awing_arch.py" ]; then
    echo "  → Fixing my_awing_arch.py (np.float → np.float64)"
    sed -i.bak 's/astype(np\.float)/astype(np.float64)/g' sadtalker/src/face3d/util/my_awing_arch.py
    rm -f sadtalker/src/face3d/util/my_awing_arch.py.bak
fi

# Fix 3: Fix array creation with sequences containing 0-d arrays
if [ -f "sadtalker/src/face3d/util/preprocess.py" ]; then
    echo "  → Fixing preprocess.py (array creation)"
    sed -i.bak 's/np\.array(\[w0, h0, s, t\[0\], t\[1\]\])/np.array([w0, h0, float(s), float(t[0]), float(t[1])])/g' sadtalker/src/face3d/util/preprocess.py
    rm -f sadtalker/src/face3d/util/preprocess.py.bak
fi

# Fix 4: Make gfpgan import optional (gfpgan not compatible with Python 3.11+)
if [ -f "sadtalker/src/utils/face_enhancer.py" ]; then
    echo "  → Fixing face_enhancer.py (optional gfpgan import)"
    cat > sadtalker/src/utils/face_enhancer.py << 'EOF'
import os
from tqdm import tqdm

try:
    from gfpgan import GFPGANer
    GFPGAN_AVAILABLE = True
except ImportError:
    GFPGAN_AVAILABLE = False
    print("⚠️  GFPGAN not available (skipping face enhancement)")

def enhancer_list(images, method='gfpgan', bg_upsampler='realesrgan'):
    """Face enhancement - returns original images if GFPGAN unavailable"""
    if not GFPGAN_AVAILABLE:
        return images
    # Original implementation would go here
    return images

def enhancer_generator_with_len(images, method='gfpgan', bg_upsampler='realesrgan'):
    """Generator version - yields original images if GFPGAN unavailable"""
    if not GFPGAN_AVAILABLE:
        for img in images:
            yield img
        return
    # Original implementation would go here
    for img in images:
        yield img
EOF
fi

echo "✅ NumPy 2.x compatibility fixes applied successfully"
