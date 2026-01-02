#!/bin/bash
# Check RunPod video generation status

echo "=== Checking for completed video ==="
ls -lh /workspace/atenea/output.mp4 2>/dev/null && echo "✅ Output video found!" || echo "❌ No output.mp4 found"

echo ""
echo "=== Checking SadTalker results directory ==="
find /workspace/atenea -name "*.mp4" -type f 2>/dev/null | head -20

echo ""
echo "=== Checking for running processes ==="
ps aux | grep -E "(python|sadtalker)" | grep -v grep

echo ""
echo "=== Checking for screen sessions ==="
screen -ls

echo ""
echo "=== Recent logs (if any) ==="
find /workspace/atenea -name "*.log" -type f -mtime -1 2>/dev/null | while read log; do
  echo "--- $log ---"
  tail -20 "$log"
done

echo ""
echo "=== Disk usage ==="
df -h /workspace
