# AI-Generated Human Avatar Video: Cost-Effective Approaches

## Overview

This document summarizes options for automating realistic AI-generated avatar videos while minimizing costs compared to services like Google Veo (~$0.20 per 8 seconds).

---

## Hardware Context

**Local Machine:** MacOS M3 with 16GB RAM

The M3 chip is capable of ML inference via Metal (MPS) acceleration and unified memory architecture, but 16GB RAM limits which models can run locally.

---

## Open Source Models Comparison

| Model         | VRAM/RAM Needed | M3 16GB Feasible? | Quality     | Notes                                         |
| ------------- | --------------- | ----------------- | ----------- | --------------------------------------------- |
| SadTalker     | ~6-8GB          | ✅ Yes            | Medium-Good | Well-optimized, good MPS support              |
| Wav2Lip       | ~4GB            | ✅ Yes            | Medium      | Lip-sync only, very lightweight               |
| LivePortrait  | ~8-10GB         | ⚠️ Tight          | Good        | May cause memory swapping                     |
| Hallo/Hallo2  | ~12-16GB        | ⚠️ Borderline     | Very Good   | Possible with optimizations (fp16, lower res) |
| EMO (Alibaba) | ~24GB+          | ❌ No             | Excellent   | Requires cloud GPU                            |

---

## Recommended Approach

### Start Local

1. **SadTalker** - First choice for local execution. Runs comfortably on M3 16GB with realistic results.
2. **Hallo2** - Test if higher quality is needed; may require optimization tweaks.

### Scale to Cloud When Needed

Use cloud resources for:

- EMO-level quality (most realistic)
- Batch processing at scale
- Consistent 1080p+ output

---

## Cloud GPU Options (Cost-Effective)

| Provider    | Instance Type       | Approximate Cost | Best For                |
| ----------- | ------------------- | ---------------- | ----------------------- |
| RunPod      | A10 / RTX 4090 spot | ~$0.30-0.50/hr   | General workloads       |
| Vast.ai     | Various GPUs        | ~$0.20-0.50/hr   | Cheapest spot instances |
| Modal       | Pay-per-second      | Variable         | Bursty automation       |
| Lambda Labs | A10 / A100          | ~$0.60-1.00/hr   | Longer sessions         |

**Cost comparison:** A batch of videos costing ~$1-2 on cloud GPUs would cost $10+ on API services like Veo.

---

## Suggested Pipeline Architecture

```
┌─────────────────┐     ┌──────────────────────┐     ┌─────────────────┐
│  Audio Gen      │ ──▶ │  Face Animation      │ ──▶ │  Post-Process   │
│  (TTS)          │     │  (SadTalker/Hallo)   │     │  (ffmpeg)       │
└─────────────────┘     └──────────────────────┘     └─────────────────┘
```

### TTS Options (Audio Generation)

- **ElevenLabs** - High quality, API pricing
- **OpenAI TTS** - Good quality, reasonable cost
- **Coqui/XTTS** - Free, runs locally

---

## Quick Start: SadTalker on M3

```bash
# Clone repository
git clone https://github.com/OpenTalker/SadTalker
cd SadTalker

# Install dependencies
pip install -r requirements.txt

# Run (auto-detects MPS acceleration)
python inference.py --driven_audio <audio.wav> --source_image <image.png>
```

---

## Decision Matrix

| Scenario                              | Recommendation                       |
| ------------------------------------- | ------------------------------------ |
| Occasional videos, acceptable quality | Local SadTalker                      |
| Higher quality needed, low volume     | Local Hallo2 with optimizations      |
| Batch processing or top-tier quality  | Cloud GPU (RunPod/Vast.ai)           |
| Production scale automation           | Cloud with spot instances + fallback |

---

## Cost Summary

| Method           | Cost per ~8 sec video |
| ---------------- | --------------------- |
| Google Veo       | ~$0.20                |
| Local (M3)       | $0 (electricity only) |
| Cloud GPU (spot) | ~$0.01-0.05           |
| HeyGen/Synthesia | ~$0.10-0.30           |

---

_Generated: December 2024_
