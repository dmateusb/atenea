# RunPod Setup Guide for SadTalker Video Generation

## Estimación de Costos

### Configuración Recomendada
- **GPU**: RTX 3090 (24GB VRAM)
- **Costo**: ~$0.34/hora
- **Resolución**: 512x512 (alta calidad para TikTok/Instagram)
- **Duración del script**: ~90 segundos de audio
- **Tiempo de procesamiento estimado**: 3-5 minutos

### Cálculo de Costos
```
Tiempo de generación: ~4 minutos
Costo por minuto: $0.34/60 = $0.00567
Costo total por video: 4 × $0.00567 = $0.023

COSTO ESTIMADO: $0.02-0.03 por video de 90 segundos
```

Para 100 videos: ~$2.30-$3.00

---

## Setup Instructions

### 1. Crear Pod en RunPod

1. Ve a https://www.runpod.io/console/pods
2. Selecciona **GPU Cloud**
3. Elige template: **RunPod PyTorch 2.1** (ya incluye CUDA 12.1)
4. GPU Recomendada:
   - **RTX 4090** (24GB) - $0.59/hr - ⭐ Más rápida (2-3 min/video)
   - **RTX 4000 Ada** (20GB) - $0.26/hr - Más económica (4-5 min/video)
5. Tipo: **Spot Instance** (30% más barato si no necesitas garantía)
6. Disco: **50GB Container Disk**
7. Click **Deploy**

### 2. Conectar al Pod

Una vez el pod esté listo, click en **Connect** → **Start Jupyter Lab** o **SSH**

### 3. Setup del Proyecto

```bash
# Clonar el repositorio
git clone https://github.com/dmateusb/atenea.git
cd atenea

# Crear virtual environment
python -m venv venv
source venv/bin/activate

# Instalar dependencias
pip install --upgrade pip
pip install -r requirements.txt

# Clonar SadTalker (repositorio externo)
git clone https://github.com/OpenTalker/SadTalker.git sadtalker

# Descargar modelos de SadTalker (~3GB, toma 5-10 minutos)
chmod +x download_models.sh
./download_models.sh
```

**Nota**: SadTalker NO está en el repositorio de Atenea porque:
- Es un repositorio externo
- Los modelos pesan ~3GB
- Se clona automáticamente durante el setup

### 4. Verificar GPU y PyTorch

El template ya incluye PyTorch 2.1 con CUDA. Verifica la instalación:

```bash
# Verificar CUDA
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
# Debe mostrar: CUDA available: True

# Verificar versión y GPU
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA: {torch.version.cuda}'); print(f'GPU: {torch.cuda.get_device_name(0)}')"
# Debe mostrar algo como:
# PyTorch: 2.1.2+cu121
# CUDA: 12.1
# GPU: NVIDIA GeForce RTX 4090
```

**Si necesitas reinstalar PyTorch con CUDA:**
```bash
# Para CUDA 12.1 (RTX 4090, RTX 4000 Ada - Recomendado)
pip install torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 --index-url https://download.pytorch.org/whl/cu121

# Para CUDA 11.8 (RTX 3090, GPUs más antiguas)
pip install torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 --index-url https://download.pytorch.org/whl/cu118
```

### 5. Generar Video

```bash
# Asegúrate de tener:
# - input.txt con tu script
# - data/images/avatar.png con tu imagen

# Ejecutar generación (con GPU cuda será automático)
npm run dev -- generate

# O directamente con Python:
python python/generate_video.py \
  --image data/images/avatar.png \
  --audio data/audio/speech_xxxxx.mp3 \
  --output output.mp4
```

### 6. Descargar Resultado

```bash
# Desde Jupyter Lab, haz click derecho en output.mp4 → Download

# O con SCP desde tu máquina local:
scp root@<pod-ip>:/workspace/atenea/output.mp4 ./
```

### 7. **IMPORTANTE**: Detener el Pod

Una vez termines, **DETÉN EL POD** para no seguir pagando:
1. RunPod Console → Pods
2. Click en tu pod → **Stop** o **Terminate**

---

## Configuración Optimizada para RunPod

### Ajustar resolución a 512x512

El archivo `python/generate_video.py` detectará automáticamente CUDA y usará GPU.

Para forzar 512x512 (mejor calidad):

```bash
# Editar python/generate_video.py línea 59
'--size', '512',  # Alta calidad para RunPod GPU
```

### Script para generación batch

Si quieres generar múltiples videos:

```bash
# generate_batch.sh
#!/bin/bash

for script in scripts/*.txt; do
  filename=$(basename "$script" .txt)

  # Actualizar input.txt
  cp "$script" input.txt

  # Generar
  npm run dev -- generate

  # Renombrar output
  mv output.mp4 "videos/${filename}.mp4"

  echo "✅ Generated: ${filename}.mp4"
done

echo "📊 Total cost: \$$(echo \"scale=2; 0.023 * $(ls videos/*.mp4 | wc -l)\" | bc)"
```

---

## Comparación de Costos

| Plataforma | GPU | Costo/hora | Tiempo/video | Costo/video | Notas |
|------------|-----|------------|--------------|-------------|-------|
| **RunPod RTX 3090** | 24GB | $0.34 | 4 min | $0.023 | ⭐ Recomendado |
| RunPod RTX 4090 | 24GB | $0.69 | 2 min | $0.023 | Más rápido, mismo costo |
| RunPod A4000 | 16GB | $0.29 | 5 min | $0.024 | Más barato |
| Modal T4 | 16GB | ~$0.50 | 6 min | $0.050 | Serverless |
| Local M3 CPU | N/A | $0 | 15+ min* | $0 | *Si completa |

---

## Tips para Reducir Costos

1. **Prepara todo localmente**: Ten input.txt y avatar.png listos antes de iniciar pod
2. **Batch processing**: Genera múltiples videos en una sesión
3. **Usa spot instances**: Hasta 70% más barato (puede interrumpirse)
4. **Detén inmediatamente**: No dejes el pod corriendo
5. **Template personalizado**: Crea template con dependencias pre-instaladas

---

## Troubleshooting

### Error: CUDA out of memory
```bash
# Reduce resolución a 384x384
# En python/generate_video.py cambiar:
'--size', '384',
```

### Error: Missing checkpoints
```bash
# Re-descargar modelos
cd sadtalker
rm -rf checkpoints/*
../download_models.sh
```

### Video no se genera
```bash
# Verificar logs
tail -f /tmp/sadtalker.log

# Test GPU
python -c "import torch; print(torch.cuda.get_device_name(0))"
```

---

## Estimación Final

### Para tu script actual (90 segundos):
- **Tiempo**: 3-5 minutos
- **Costo**: $0.02-0.03
- **Resolución**: 512x512 (1280x720 después de crop)
- **Calidad**: Excelente para TikTok/Instagram

### Para 10 videos al día durante un mes:
- **Total videos**: 300
- **Tiempo total**: ~20 horas
- **Costo total**: $6-9/mes

**Mucho más económico que tu Mac local en tiempo y electricidad!**
