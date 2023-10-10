#!/usr/bin/env bash
export PYTHONUNBUFFERED=1

echo "Container is running"

# Sync venv to workspace to support Network volumes
echo "Syncing venv to workspace, please wait..."
rsync -au /venv/ /workspace/venv/

# Sync LLaVA to workspace to support Network volumes
echo "Syncing LLaVA to workspace, please wait..."
rsync -au /LLaVA/ /workspace/LLaVA/

# Fix the venv to make it work from /workspace
echo "Fixing venv..."
/fix_venv.sh /venv /workspace/venv

if [[ ${DISABLE_AUTOLAUNCH} ]]
then
    echo "Auto launching is disabled so the application will not be started automatically"
else
    mkdir -p /workspace/logs
    echo "Starting LLaVA"
    export HF_HOME="/workspace"
    source /workspace/venv/bin/activate
    cd /workspace/LLaVA

    # Launch a controller
    nohup python3 -m llava.serve.controller --host 0.0.0.0 --port 10000 > /workspace/logs/controller.log 2>&1 &

    # Launch a gradio web server
    export GRADIO_SERVER_NAME="0.0.0.0"
    export GRADIO_SERVER_PORT="3001"
    nohup python -m llava.serve.gradio_web_server --controller http://localhost:10000 --model-list-mode reload > /workspace/logs/webserver.log 2>&1 &

    # Launch a model worker
    nohup python3 -m llava.serve.model_worker --host 0.0.0.0 --controller http://localhost:10000 --port 40000 --worker http://localhost:40000 --model-path liuhaotian/llava-v1.5-13b > /workspace/logs/model-worker.log 2>&1 &

    echo "LLaVA started"
    echo "Log files: "
    echo "   - Controller:   /workspace/logs/controller.log"
    echo "   - Webserver:    /workspace/logs/webserver.log"
    echo "   - Model Worker: /workspace/logs/model-worker.log"
    deactivate
fi

echo "All services have been started"