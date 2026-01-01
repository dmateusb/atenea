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

echo "✅ NumPy 2.x compatibility fixes applied successfully"
