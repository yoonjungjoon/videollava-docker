# Stage 1: Base
FROM pytorch/pytorch:2.1.2-cuda11.8-cudnn8-devel

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN conda install git tmux -y

# Install xformers
ARG INDEX_URL
ARG TORCH_VERSION
ARG XFORMERS_VERSION
RUN pip install --no-cache-dir xformers==${XFORMERS_VERSION} --index-url ${INDEX_URL}

# Clone the git repo of LLaVA and set version
ARG LLAVA_COMMIT
RUN git clone https://github.com/ashleykleynhans/LLaVA.git && \
    cd /workspace/LLaVA && \
    git checkout ${LLAVA_COMMIT}

# Install the dependencies for LLaVA
WORKDIR /workspace/LLaVA
RUN pip install --upgrade pip && \
    pip install wheel && \
    pip install -e . && \
    pip install ninja protobuf flask transformers==4.37.2 && \
    pip install flash-attn --no-build-isolation

# Copy the scripts
COPY --chmod=755 scripts /workspace/scripts

# Download the default model
ARG LLAVA_MODEL
ARG INCLUDE_CHECKPOINT
ENV MODEL="${LLAVA_MODEL}"
ENV HF_HOME="/workspace"
RUN pip install huggingface_hub
RUN if [ "${INCLUDE_CHECKPOINT}" = "true" ]; then \
    python /workspace/scripts/download_models.py; \
    fi

# Set template version
ARG RELEASE
ENV TEMPLATE_VERSION=${RELEASE}

# Start the container
WORKDIR /workspace
CMD [ "/workspace/scripts/start.sh" ]
