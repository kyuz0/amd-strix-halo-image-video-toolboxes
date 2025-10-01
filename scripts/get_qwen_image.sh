#!/usr/bin/env bash
# /opt/get_qwen.sh (resume-friendly, supports Qwen Image + Qwen Image Edit)
set -euo pipefail

export HF_HUB_ENABLE_HF_TRANSFER=1
export HF_HOME="${HF_HOME:-$HOME/.cache/huggingface}"   # persistent HF cache
HF="/opt/venv/bin/hf"

MODEL_HOME="$HOME/comfy-ui/models"
STAGE="$MODEL_HOME/.hf_stage_qwen"                      # persistent staging (resume support)

mkdir -p "$MODEL_HOME"/{text_encoders,vae,diffusion_models}
mkdir -p "$STAGE"

dl() {
  local repo="$1"; shift
  local remote="$1"; shift
  local subdir="$1"; shift
  local dest="$MODEL_HOME/$subdir/$(basename "$remote")"
  local staged="$STAGE/$remote"

  if [[ -f "$dest" ]]; then
    echo "✓ Already present: $dest"
    return
  fi

  echo "↓ Downloading $(basename "$remote") → $dest"
  mkdir -p "$(dirname "$staged")"
  "$HF" download "$repo" "$remote" \
      --repo-type model \
      --cache-dir "$HF_HOME" \
      --local-dir "$STAGE"
  mv -f "$staged" "$dest"
}

echo "Which Qwen variant do you want to download?"
echo "  1) Qwen-Image (20B text-to-image)"
echo "  2) Qwen-Image-Edit (image editing)"
read -rp "Enter 1 or 2: " choice

case "$choice" in
  1)
    REPO="Comfy-Org/Qwen-Image_ComfyUI"
    echo "==> Downloading Qwen-Image (20B)"
    dl "$REPO" "split_files/diffusion_models/qwen_image_fp8_e4m3fn.safetensors" "diffusion_models"
    dl "$REPO" "split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors" "text_encoders"
    dl "$REPO" "split_files/vae/qwen_image_vae.safetensors" "vae"
    ;;
  2)
    REPO="Comfy-Org/Qwen-Image-Edit_ComfyUI"
    echo "==> Downloading Qwen-Image-Edit"
    # Requires text encoder + VAE from Qwen-Image
    BASE="Comfy-Org/Qwen-Image_ComfyUI"
    dl "$BASE" "split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors" "text_encoders"
    dl "$BASE" "split_files/vae/qwen_image_vae.safetensors" "vae"
    dl "$REPO" "split_files/diffusion_models/qwen_image_edit_fp8_e4m3fn.safetensors" "diffusion_models"
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

echo "✓ Models ready in $MODEL_HOME"
