variable "USERNAME" {
    default = "ashleykza"
}

variable "APP" {
    default = "llava"
}

variable "RELEASE" {
    default = "1.4.6"
}

variable "CU_VERSION" {
    default = "118"
}

target "default" {
    dockerfile = "Dockerfile"
    tags = ["${USERNAME}/${APP}:${RELEASE}"]
    args = {
        RELEASE = "${RELEASE}"
        INDEX_URL = "https://download.pytorch.org/whl/cu${CU_VERSION}"
        TORCH_VERSION = "2.1.2+cu${CU_VERSION}"
        XFORMERS_VERSION = "0.0.23.post1+cu${CU_VERSION}"
        LLAVA_COMMIT = "fd3f3d29c418ccfca618cc96a8c3f63302b3bda7"
        LLAVA_MODEL = "liuhaotian/llava-v1.6-mistral-7b"
        RUNPODCTL_VERSION = "v1.14.2"
        VENV_PATH = "/workspace/venvs/${APP}"
    }
}
