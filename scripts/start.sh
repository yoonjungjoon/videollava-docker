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

# Downloading checkpoints to /workspace
echo "Downloading checkpoints to /workspace"
python /workspace/scripts/download_models.py

# Mkdir logs
mkdir -p /workspace/logs

# Start the model worker and web server
cd /workspace/LLaVA

/opt/conda/bin/python -m llava.serve.controller \
    --host ${LLAVA_HOST} \
    --port ${LLAVA_CONTROLLER_PORT} > /workspace/logs/controller.log 2>&1 &

/opt/conda/bin/python -m llava.serve.model_worker \
    --host ${LLAVA_HOST} \
    --controller http://localhost:${LLAVA_CONTROLLER_PORT} \
    --port ${LLAVA_MODEL_WORKER_PORT} \
    --worker http://localhost:${LLAVA_MODEL_WORKER_PORT} \
    --model-path ${LLAVA_MODEL} > /workspace/logs/model-worker.log 2>&1 &

/opt/conda/bin/python -m llava.serve.gradio_web_server \
    --controller http://localhost:${LLAVA_CONTROLLER_PORT} \
    --model-list-mode reload > /workspace/logs/webserver.log 2>&1 &

echo "Container is READY!"
echo "You can access the web server at http://${GRADIO_SERVER_NAME}:${GRADIO_SERVER_PORT}"
echo "Grab logs at /workspace/logs in the container"
sleep infinity
