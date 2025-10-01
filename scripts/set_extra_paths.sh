#!/bin/bash
# setup_extra_paths.sh

set -euo pipefail

CONFY_DIR="/opt/ComfyUI"
YAML_FILE="$CONFY_DIR/extra_model_paths.yaml"
MODEL_DIR="$HOME/comfy-models"

mkdir -p "$MODEL_DIR"/{checkpoints,text_encoders,vae,diffusion_models,unet,clip,clip_vision,configs,controlnet,embeddings,loras,upscale_models}

cat > "$YAML_FILE" <<EOF
comfyui:
    base_path: $MODEL_DIR

    checkpoints: checkpoints
    text_encoders: text_encoders
    vae: vae
    diffusion_models: diffusion_models
    unet: unet
    clip: clip
    clip_vison: clip_vision
    configs: configs
    controlnet: controlnet
    embeddings: embeddings
    loras: loras
    upscale_models: upscale_models
EOF

echo "✅ Wrote $YAML_FILE"
