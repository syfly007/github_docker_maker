# 使用nvidia/cuda作为基础镜像
ARG NVIDIA_CUDA_VERSION="11.7.1"
FROM nvidia/cuda:${NVIDIA_CUDA_VERSION}-cudnn8-runtime-ubuntu22.04

RUN apt-get clean && \
    apt-get update && \
    apt-get install -y git python3 python3-venv libgl1 libglib2.0-0 sudo wget vim fonts-dejavu-core rsync moreutils aria2 \
    ffmpeg libglfw3-dev libgles2-mesa-dev pkg-config libcairo2 libcairo2-dev build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# 创建新用户sd并添加到sudo组
RUN useradd -ms /bin/bash sd && echo "sd:sd" | chpasswd && adduser sd sudo

# 为了使 sd 用户可以使用 sudo 命令而不需要密码
RUN echo "sd ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# 切换到sd用户
USER sd

# 定义工作目录
WORKDIR /home/sd/

# 下载并安装Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_24.1.2-0-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p $HOME/miniconda && \
    rm ~/miniconda.sh && \
    /home/sd/miniconda/bin/conda clean -ya

# 将Conda的bin路径添加到PATH中
ENV PATH="/home/sd/miniconda/bin:$PATH"

# 克隆stable-diffusion-webui
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /home/sd/stable-diffusion-webui

WORKDIR /home/sd/stable-diffusion-webui/repositories
# install repositories
RUN git clone https://github.com/Stability-AI/stablediffusion.git /home/sd/stable-diffusion-webui/repositories/stable-diffusion-stability-ai && \
    git clone https://github.com/sczhou/CodeFormer.git && \
    git clone https://github.com/salesforce/BLIP.git && \
    git clone https://github.com/crowsonkb/k-diffusion.git && \
    git clone https://github.com/pharmapsychotic/clip-interrogator && \
    git clone https://github.com/Stability-AI/generative-models

WORKDIR /home/sd/stable-diffusion-webui/extensions
# install plugins
RUN git clone https://github.com/AlUlkesh/stable-diffusion-webui-images-browser && \
    git clone https://github.com/camenduru/sd-civitai-browser && \
    git clone https://github.com/butaixianran/Stable-Diffusion-Webui-Civitai-Helper && \
    git clone https://github.com/DominikDoom/a1111-sd-webui-tagcomplete && \
    git clone https://github.com/deforum-art/deforum-for-automatic1111-webui.git && \
    git clone https://github.com/Mikubill/sd-webui-controlnet.git && \
    git clone https://github.com/Physton/sd-webui-prompt-all-in-one

# 进入 stable-diffusion-webui 目录并执行 webui.sh 脚本
WORKDIR /home/sd/stable-diffusion-webui

RUN pip3 install --upgrade pip && \
    pip install -r requirements_versions.txt && \
    pip install -r repositories/CodeFormer/requirements.txt && \
    pip install -r repositories/k-diffusion/requirements.txt && \
    pip install xformers && \
    pip install httpx[socks] && \
    pip3 cache purge

RUN rm -Rf \
  /home/sd/.cache \
  /tmp \
  /var/lib/apt/lists/* \
  /root/miniconda/pkgs/* \
  /var/tmp/*
RUN mkdir -m 1777 /tmp

EXPOSE 7860