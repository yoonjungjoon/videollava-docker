# Docker image for LLaVA: Large Language and Vision Assistant

## Installs

* Ubuntu 22.04 LTS
* CUDA 11.8
* Python 3.10.12
* [LLaVA](
  https://github.com/haotian-liu/llava) v1.1.1
* Torch 2.1.0
* BakLLaVA-1 model

## Available on RunPod

This image is designed to work on [RunPod](https://runpod.io?ref=2xxro4sy).
You can use my custom [RunPod template](
https://runpod.io/gsc?template=g7wd33iuwv&ref=2xxro4sy)
to launch it on RunPod.

## Running Locally

### Install Nvidia CUDA Driver

- [Linux](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html)
- [Windows](https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html)

### Start the Docker container

```bash
docker run -d \
  --gpus all \
  -v /workspace \
  -p 3000:3001 \
  -p 8888:8888 \
  -e JUPYTER_PASSWORD=Jup1t3R! \
  ashleykza/llava:latest
```

You can obviously substitute the image name and tag with your own.

#### Models

> [!IMPORTANT]
> If you select the 13b model, CUDA will result in OOM errors
> with a GPU that has less than 48GB of VRAM, so A6000 or higher is
> recommended.

You can add an environment called `MODEL` to your Docker container to
specify the model that should be downloaded.  If the `MODEL` environment
variable is not set, the model will default to `SkunkworksAI/BakLLaVA-1`.

| Model                                                              | Environment Variable Value  | Default |
|--------------------------------------------------------------------|-----------------------------|---------|
| [llava-v1.5-13b](https://huggingface.co/liuhaotian/llava-v1.5-13b) | liuhaotian/llava-v1.5-13b   | no      |
| [llava-v1.5-7b](https://huggingface.co/liuhaotian/llava-v1.5-7b)   | liuhaotian/llava-v1.5-7b    | no      |
| [BakLLaVA-1](https://huggingface.co/SkunkworksAI/BakLLaVA-1)       | SkunkworksAI/BakLLaVA-1     | yes     |

## Acknowledgements

1. Matthew Berman for giving me a demo on LLaVA, as well as his amazing
   [YouTube videos](https://www.youtube.com/@matthew_berman/videos]).

## Community and Contributing

Pull requests and issues on [GitHub](https://github.com/ashleykleynhans/llava-docker)
are welcome. Bug fixes and new features are encouraged.

You can contact me and get help with deploying your container
to RunPod on the RunPod Discord Server below,
my username is **ashleyk**.

<a target="_blank" href="https://discord.gg/pJ3P2DbUUq">![Discord Banner 2](https://discordapp.com/api/guilds/912829806415085598/widget.png?style=banner2)</a>

## Appreciate my work?

<a href="https://www.buymeacoffee.com/ashleyk" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
