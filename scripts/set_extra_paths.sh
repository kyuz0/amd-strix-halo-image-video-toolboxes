#!/bin/bash
# setup_extra_paths.sh

set -euo pipefail

CONFY_DIR="/opt/ComfyUI"
YAML_FILE="$CONFY_DIR/extra_model_paths.yaml"
MODEL_DIR="$HOME/comfy-models"

mkdir -p "$MODEL_DIR"/{text_encoders,vae,diffusion_models}

cat > "$YAML_FILE" <<EOF
comfyui:
    base_path: $MODEL_DIR

    text_encoders: text_encoders
    vae: vae
    diffusion_models: diffusion_models
    unet: unet
EOF

echo "✅ Wrote $YAML_FILE"
