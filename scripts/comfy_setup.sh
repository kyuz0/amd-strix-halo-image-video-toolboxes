#! /usr/bin/env bash

mkdir -p "$HOME/comfy-ui"
cp -r /opt/ComfyUI/models "$HOME/comfy-ui/models"
git clone --depth=1 https://github.com/cubiq/ComfyUI_essentials "$HOME/comfy-ui/custom_nodes/ComfyUI_essentials"
git clone --depth=1 https://github.com/kyuz0/ComfyUI-AMDGPUMonitor "$HOME/comfy-ui/custom_nodes/ComfyUI-AMDGPUMonitor"
git clone --depth=1 https://github.com/Comfy-Org/ComfyUI-Manager "$HOME/comfy-ui/custom_nodes/ComfyUI-Manager"