#!/usr/bin/env bash
# /opt/get_wan22.sh  (resume-friendly)
set -euo pipefail

export HF_HUB_ENABLE_HF_TRANSFER=1
export HF_HOME="${HF_HOME:-$HOME/.cache/huggingface}"   # persistent HF cache
HF="/opt/venv/bin/hf"

MODEL_HOME="$HOME/comfy-models"
REPO="Comfy-Org/Wan_2.2_ComfyUI_Repackaged"
STAGE="$MODEL_HOME/.hf_stage_wan22"                     # persistent staging (enables resume)

mkdir -p "$MODEL_HOME"/{text_encoders,vae,diffusion_models}
mkdir -p "$STAGE"

download_if_missing () {
  local repo="$1";
  local remote="$2";
  local subdir="$3";
  local dest_dir="$MODEL_HOME/$subdir"
  local dest_file="$dest_dir/$(basename "$remote")"
  local staged="$STAGE/$remote"

  if [[ -f "$dest_file" ]]; then
    echo "✓ Already present: $dest_file"
    return
  fi

  echo "↓ Downloading $(basename "$remote") → $dest_file"
  mkdir -p "$(dirname "$staged")"        # ensure stage path exists
  "$HF" download "$repo" "$remote" \
      --repo-type model \
      --cache-dir "$HF_HOME" \
      --local-dir "$STAGE"
  mv -f "$staged" "$dest_file"
}

usage() {
  cat <<'USAGE'
Usage: get_wan22.sh <target>

Targets:
  common     Text encoder + VAEs (needed first)
             - text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors
             - vae/wan_2.1_vae.safetensors      (for 14B)
             - vae/wan2.2_vae.safetensors       (for 5B)

  5b         5B TI2V diffusion model
             - diffusion_models/wan2.2_ti2v_5B_fp16.safetensors
             Requires: common (uses wan2.2_vae)

  14b-t2v    14B Text→Video diffusion models (high/low noise)
             - diffusion_models/wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors
             - diffusion_models/wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors
             Requires: common (uses wan_2.1_vae)

  14b-i2v    14B Image→Video diffusion models (high/low noise)
             - diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors
             - diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors
             Requires: common (uses wan_2.1_vae)

Maintenance:
  clean-stage   Remove staging folder (keeps final models)
  clean-cache   Remove Hugging Face cache (~/.cache/huggingface)

Notes:
- Downloads RESUME automatically via persistent --cache-dir and --local-dir.
- Files end up in: $HOME/comfy-models/<text_encoders|vae|diffusion_models>
USAGE
}

case "${1:-}" in
  common)
    echo "==> text encoder + VAEs"
    download_if_missing "$REPO" "split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" "text_encoders"
    download_if_missing "$REPO" "split_files/vae/wan_2.1_vae.safetensors" "vae"
    download_if_missing "$REPO" "split_files/vae/wan2.2_vae.safetensors" "vae"
    ;;
  5b)
    echo "==> 5B TI2V"
    download_if_missing "$REPO" "split_files/diffusion_models/wan2.2_ti2v_5B_fp16.safetensors" "diffusion_models"
    ;;
  14b-t2v)
    echo "==> 14B Text→Video"
    download_if_missing "$REPO" "split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors" "diffusion_models"
    download_if_missing "$REPO" "split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors" "diffusion_models"
    ;;
  14b-i2v)
    echo "==> 14B Image→Video"
    download_if_missing "$REPO" "split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors" "diffusion_models"
    download_if_missing "$REPO" "split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors" "diffusion_models"
    ;;
  clean-stage)
    rm -rf "$STAGE"; echo "✓ Removed stage: $STAGE"
    ;;
  clean-cache)
    rm -rf "$HF_HOME"; echo "✓ Removed HF cache: $HF_HOME"
    ;;
  ""|-h|--help|help)
    usage
    ;;
  *)
    echo "Unknown target: $1" >&2
    usage
    exit 1
    ;;
esac

echo "✓ Done."
