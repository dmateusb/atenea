#!/bin/bash
# Debug script to capture full error output and system state

LOGFILE="/workspace/atenea/debug_$(date +%Y%m%d_%H%M%S).log"

echo "=== System Info ===" | tee -a "$LOGFILE"
nvidia-smi 2>&1 | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"
free -h 2>&1 | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

echo "=== Python Info ===" | tee -a "$LOGFILE"
python3 --version 2>&1 | tee -a "$LOGFILE"
python3 -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}')" 2>&1 | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

echo "=== Starting Generation ===" | tee -a "$LOGFILE"
cd /workspace/atenea

# Run with verbose error output
npm run generate 2>&1 | tee -a "$LOGFILE"

EXIT_CODE=$?
echo "" | tee -a "$LOGFILE"
echo "=== Process Exit Code: $EXIT_CODE ===" | tee -a "$LOGFILE"

if [ $EXIT_CODE -ne 0 ]; then
    echo "=== System State After Crash ===" | tee -a "$LOGFILE"
    nvidia-smi 2>&1 | tee -a "$LOGFILE"
    echo "" | tee -a "$LOGFILE"
    dmesg | tail -50 2>&1 | tee -a "$LOGFILE"
fi

echo "" | tee -a "$LOGFILE"
echo "Full log saved to: $LOGFILE"
