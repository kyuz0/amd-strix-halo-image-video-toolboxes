#! /usr/bin/env bash
set -euo pipefail

# Setup $HOME comfyui base directory, copying models template provided in repo
mkdir -p "$HOME/comfy-ui"
cp -r /opt/ComfyUI/models "$HOME/comfy-ui/models"
# Install essential extensions, or don't if they're already present.
[ ! -d "$HOME/comfy-ui/custom_nodes/ComfyUI_essentials" ] && git clone  https://github.com/cubiq/ComfyUI_essentials "$HOME/comfy-ui/custom_nodes/ComfyUI_essentials"
[ ! -d "$HOME/comfy-ui/custom_nodes/ComfyUI-AMDGPUMonitor" ] && git clone  https://github.com/kyuz0/ComfyUI-AMDGPUMonitor "$HOME/comfy-ui/custom_nodes/ComfyUI-AMDGPUMonitor"
[ ! -d "$HOME/comfy-ui/custom_nodes/ComfyUI-Manager" ] && git clone  https://github.com/Comfy-Org/ComfyUI-Manager "$HOME/comfy-ui/custom_nodes/ComfyUI-Manager"

# Install all requirements as needed.
for dir in $HOME/comfy-ui/custom_nodes/* ; do
    pushd $dir
    [ -f requirements.txt ] && pip install -r requirements.txt
    popd
done

# Change ownership of ComfyUI to enable ComfyUI manager to use git to update ComfyUI.
sudo chown -R $USER /opt/ComfyUI

cd /opt/ComfyUI
