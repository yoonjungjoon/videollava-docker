# Docker image for LLaVA: Large Language and Vision Assistant

## Usage (locally)

### Install Nvidia CUDA Driver

- [Linux](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html)
- [Windows](https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html)

### Start the Docker container

```bash
docker run -d \
  --gpus all \
  -v /workspace \
  -v {your_path_to_hugging_face_cache}/hub:/workspace/hub \
  -p 3000:3001 \
  meihaiyi/llava:latest
```

### Building the Docker image

> [!NOTE]
> You will need to edit the `docker-bake.hcl` file and update `USERNAME`,
> and `RELEASE`.  You can obviously edit the other values too, but these
> are the most important ones.

```bash
# Clone the repo
git clone https://github.com/haiyimei/llava-docker.git

# Log in to Docker Hub
docker login

# Build the image, tag the image, and push the image to Docker Hub
cd llava-docker
docker buildx bake -f docker-bake.hcl --push
```

## Instructions (docker)

* Ubuntu 22.04 LTS
* CUDA 11.8
* Python 3.10.12
* [LLaVA](https://github.com/haotian-liu/llava) v1.2.0 (LLaVA 1.6)
* Torch 2.1.2
* xformers 0.0.23.post1
* tmux
* (optional) llava-v1.6-mistral-7b model

### Models

> [!IMPORTANT]
> If you select a 13B or larger model, CUDA will result in OOM errors
> with a GPU that has less than 48GB of VRAM, so A6000 or higher is
> recommended for 13B.

You can add an environment called `MODEL` to your Docker container to
specify the model that should be downloaded.  If the `MODEL` environment
variable is not set, the model will default to `liuhaotian/llava-v1.6-mistral-7b`.

### LLaVA-v1.6

| Model                                                                            | Environment Variable Value       | Version    | LLM           | Default |
|----------------------------------------------------------------------------------|----------------------------------|------------|---------------|---------|
| [llava-v1.6-vicuna-7b](https://huggingface.co/liuhaotian/llava-v1.6-vicuna-7b)   | liuhaotian/llava-v1.6-vicuna-7b  | LLaVA-1.6  | Vicuna-7B     | no      |
| [llava-v1.6-vicuna-13b](https://huggingface.co/liuhaotian/llava-v1.6-vicuna-13b) | liuhaotian/llava-v1.6-vicuna-13b | LLaVA-1.6  | Vicuna-13B    | no      |
| [llava-v1.6-mistral-7b](https://huggingface.co/liuhaotian/llava-v1.6-mistral-7b) | liuhaotian/llava-v1.6-mistral-7b | LLaVA-1.6  | Mistral-7B    | yes     |
| [llava-v1.6-34b](https://huggingface.co/liuhaotian/llava-v1.6-34b)               | liuhaotian/llava-v1.6-34b        | LLaVA-1.6  | Hermes-Yi-34B | no      |

### LLaVA-v1.5

| Model                                                              | Environment Variable Value | Version   | Size | Default |
|--------------------------------------------------------------------|----------------------------|-----------|------|---------|
| [llava-v1.5-7b](https://huggingface.co/liuhaotian/llava-v1.5-7b)   | liuhaotian/llava-v1.5-7b   | LLaVA-1.5 | 7B   | no      |
| [llava-v1.5-13b](https://huggingface.co/liuhaotian/llava-v1.5-13b) | liuhaotian/llava-v1.5-13b  | LLaVA-1.5 | 13B  | no      |
| [BakLLaVA-1](https://huggingface.co/SkunkworksAI/BakLLaVA-1)       | SkunkworksAI/BakLLaVA-1    | LLaVA-1.5 | 7B   | no      |

## Ports

| Connect Port | Internal Port | Description          |
|--------------|---------------|----------------------|
| 3000         | 3001          | LLaVA                |

## Environment Variables

| Variable             | Description                                  | Default                          |
|----------------------|----------------------------------------------|----------------------------------|
| MODEL                | The path of the Huggingface model            | liuhaotian/llava-v1.6-mistral-7b |

## Logs

LLaVA creates log files, and you can tail the log files
instead of killing the services to view the logs.

| Application   | Log file                         |
|---------------|----------------------------------|
| Controller    | /workspace/logs/controller.log   |
| Webserver     | /workspace/logs/webserver.log    |
| Model Worker  | /workspace/logs/model-worker.log |

For example:

```bash
tail -f /workspace/logs/webserver.log
```

## Flask API

### Add port 5000

If you are running the RunPod template, edit your pod and add HTTP port 5000.

If you are running locally, add a port mapping for port 5000.

### Starting the Flask API

```bash
# Stop model worker and controller to free up VRAM
fuser -k 10000/tcp 40000/tcp

# Install dependencies
source /workspace/venv/bin/activate
pip3 install flask protobuf
cd /workspace/LLaVA
export HF_HOME="/workspace"
python -m llava.serve.api -H 0.0.0.0 -p 5000
```

### Sending requests to the Flask API

You can use the [test script](
https://github.com/ashleykleynhans/LLaVA/blob/main/llava/serve/test_api.py)
to test your API.
