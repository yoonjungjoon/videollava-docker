#!/usr/bin/env bash

export PYTHONUNBUFFERED=1

echo "Template version: ${TEMPLATE_VERSION}"

if [[ -e "/workspace/template_version" ]]; then
    EXISTING_VERSION=$(cat /workspace/template_version)
else
    EXISTING_VERSION="0.0.0"
fi

# Sync apps to /workspace to support Network Volumes
sync_apps() {
    echo "Syncing venv to workspace, please wait..."
    rsync --remove-source-files -rlptDu /venv/ /workspace/venv/

    echo "Syncing LLaVA to workspace, please wait..."
    rsync --remove-source-files -rlptDu /LLaVA/ /workspace/LLaVA/

    echo "Syncing model to workspace, please wait..."
    rsync --remove-source-files -rlptDu /hub/ /workspace/hub/

    echo "${TEMPLATE_VERSION}" > /workspace/template_version
}

fix_venvs() {
    # Fix the venv to make it work from /workspace
    echo "Fixing venv..."
    /fix_venv.sh /venv /workspace/venv
}

if [ "$(printf '%s\n' "$EXISTING_VERSION" "$TEMPLATE_VERSION" | sort -V | head -n 1)" = "$EXISTING_VERSION" ]; then
    if [ "$EXISTING_VERSION" != "$TEMPLATE_VERSION" ]; then
        sync_apps
        fix_venvs
    else
        echo "Existing version is the same as the template version, no syncing required."
    fi
fi

if [[ ${DISABLE_AUTOLAUNCH} ]]
then
    echo "Auto launching is disabled so the application will not be started automatically"
else
    # Configure environment variables
    export LLAVA_HOST="0.0.0.0"
    export LLAVA_CONTROLLER_PORT="10000"
    export LLAVA_MODEL_WORKER_PORT="40000"
    export GRADIO_SERVER_NAME=${LLAVA_HOST}
    export GRADIO_SERVER_PORT="3001"
    export HF_HOME="/workspace"

    if [[ ${MODEL} ]]
    then
      export LLAVA_MODEL=${MODEL}
    else
      export LLAVA_MODEL="liuhaotian/llava-v1.6-mistral-7b"
    fi

    echo "Starting LLaVA using model: ${LLAVA_MODEL}"
    /start_controller.sh
    /start_model_worker.sh
    /start_webserver.sh
    echo "LLaVA started"
    echo "Log files: "
    echo "   - Controller:   /workspace/logs/controller.log"
    echo "   - Model Worker: /workspace/logs/model-worker.log"
    echo "   - Webserver:    /workspace/logs/webserver.log"
fi

echo "All services have been started"
