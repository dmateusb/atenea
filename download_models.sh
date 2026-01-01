#!/bin/bash
set -e

echo "📥 Downloading SadTalker model checkpoints..."

cd sadtalker

mkdir -p ./checkpoints
mkdir -p ./gfpgan/weights

# Download main SadTalker models (new links)
echo "Downloading mapping_00109-model.pth.tar..."
curl -L -C - https://github.com/OpenTalker/SadTalker/releases/download/v0.0.2-rc/mapping_00109-model.pth.tar -o ./checkpoints/mapping_00109-model.pth.tar

echo "Downloading mapping_00229-model.pth.tar..."
curl -L -C - https://github.com/OpenTalker/SadTalker/releases/download/v0.0.2-rc/mapping_00229-model.pth.tar -o ./checkpoints/mapping_00229-model.pth.tar

echo "Downloading SadTalker_V0.0.2_256.safetensors..."
curl -L -C - https://github.com/OpenTalker/SadTalker/releases/download/v0.0.2-rc/SadTalker_V0.0.2_256.safetensors -o ./checkpoints/SadTalker_V0.0.2_256.safetensors

echo "Downloading SadTalker_V0.0.2_512.safetensors..."
curl -L -C - https://github.com/OpenTalker/SadTalker/releases/download/v0.0.2-rc/SadTalker_V0.0.2_512.safetensors -o ./checkpoints/SadTalker_V0.0.2_512.safetensors

# Download legacy checkpoints (still needed even with safetensors)
echo "Downloading epoch_20.pth..."
curl -L -C - https://github.com/Winfredy/SadTalker/releases/download/v0.0.2/epoch_20.pth -o ./checkpoints/epoch_20.pth

echo "Downloading wav2lip.pth..."
curl -L -C - https://github.com/Winfredy/SadTalker/releases/download/v0.0.2/wav2lip.pth -o ./checkpoints/wav2lip.pth

echo "Downloading shape_predictor_68_face_landmarks.dat..."
curl -L -C - https://github.com/Winfredy/SadTalker/releases/download/v0.0.2/shape_predictor_68_face_landmarks.dat -o ./checkpoints/shape_predictor_68_face_landmarks.dat

echo "Downloading auido2pose_00140-model.pth..."
curl -L -C - https://github.com/Winfredy/SadTalker/releases/download/v0.0.2/auido2pose_00140-model.pth -o ./checkpoints/auido2pose_00140-model.pth

echo "Downloading auido2exp_00300-model.pth..."
curl -L -C - https://github.com/Winfredy/SadTalker/releases/download/v0.0.2/auido2exp_00300-model.pth -o ./checkpoints/auido2exp_00300-model.pth

echo "Downloading facevid2vid_00189-model.pth.tar..."
curl -L -C - https://github.com/Winfredy/SadTalker/releases/download/v0.0.2/facevid2vid_00189-model.pth.tar -o ./checkpoints/facevid2vid_00189-model.pth.tar

# Download GFPGAN enhancer weights (optional but recommended)
echo "Downloading GFPGAN weights..."
curl -L -C - https://github.com/xinntao/facexlib/releases/download/v0.1.0/alignment_WFLW_4HG.pth -o ./gfpgan/weights/alignment_WFLW_4HG.pth

curl -L -C - https://github.com/xinntao/facexlib/releases/download/v0.1.0/detection_Resnet50_Final.pth -o ./gfpgan/weights/detection_Resnet50_Final.pth

curl -L -C - https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.4.pth -o ./gfpgan/weights/GFPGANv1.4.pth

curl -L -C - https://github.com/xinntao/facexlib/releases/download/v0.2.2/parsing_parsenet.pth -o ./gfpgan/weights/parsing_parsenet.pth

cd ..

echo "✅ Model checkpoints downloaded successfully!"
echo "   Total size: ~3-3.5GB"
