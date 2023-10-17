#!/usr/bin/env bash
source /workspace/venv/bin/activate
cd /workspace/LLaVA
nohup python3 -m llava.serve.model_worker \
  --host ${LLAVA_HOST} \
  --controller http://localhost:${LLAVA_CONTROLLER_PORT} \
  --port ${LLAVA_MODEL_WORKER_PORT} \
  --worker http://localhost:${LLAVA_MODEL_WORKER_PORT} \
  --model-path liuhaotian/llava-v1.5-13b > /workspace/logs/model-worker.log 2>&1 &
deactivate
