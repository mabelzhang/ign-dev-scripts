# Since nvidia/opengl:*-glvnd-devel-ubuntu22.04 is not available yet, this
# builds an equivalent, to run X server in an Ubuntu 20.04 Docker image.

# 13 Jan 2022

FROM ubuntu:jammy

#####
# Following lines are copied from
# https://gitlab.com/nvidia/container-images/opengl/-/blob/ubuntu18.04/base/Dockerfile
# and removed :i386 packages (not found)
#RUN dpkg --add-architecture i386 && \
RUN apt-get update && apt-get install -y --no-install-recommends \
        libxau6 \
        libxdmcp6 \
        libxcb1 \
        libxext6 \
        libx11-6 && \
    rm -rf /var/lib/apt/lists/*

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
        ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
        ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics,compat32,utility

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

# https://gitlab.com/nvidia/container-images/opengl/-/blob/ubuntu20.04/NGC-DL-CONTAINER-LICENSE
COPY NGC-DL-CONTAINER-LICENSE /

# Required for non-glvnd setups.
ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}:/usr/local/nvidia/lib:/usr/local/nvidia/lib64

#####
# Copied from
# https://gitlab.com/nvidia/container-images/opengl/blob/ubuntu20.04/glvnd/devel/Dockerfile
# and removed :i386 packages (not found)
RUN apt-get update && apt-get install -y --no-install-recommends \
        pkg-config \
        libglvnd-dev \
        libgl1-mesa-dev \
        libegl1-mesa-dev \
        libgles2-mesa-dev && \
    rm -rf /var/lib/apt/lists/*
