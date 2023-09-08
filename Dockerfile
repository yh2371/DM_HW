# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Set environment variables to non-interactive (this prevents some prompts)
ENV DEBIAN_FRONTEND=noninteractive

# Install essential tools and dependencies
RUN apt-get update && apt-get install -y sudo && apt-get install -y \
    build-essential \
    cmake \
    git \
    libgl1-mesa-dev \
    libglew-dev \
    wget \
    xvfb \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncurses5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
 && rm -rf /var/lib/apt/lists/*


# Compile Python 3.6 from source
WORKDIR /tmp
RUN wget https://www.python.org/ftp/python/3.6.15/Python-3.6.15.tgz \
 && tar xvf Python-3.6.15.tgz \
 && cd Python-3.6.15 \
 && ./configure --prefix=/usr --enable-optimizations --enable-shared \
 && make altinstall

RUN if [ -f /usr/bin/python3 ]; then rm /usr/bin/python3; fi && ln -s /usr/bin/python3.6 /usr/bin/python3
RUN if [ -f /usr/bin/python ]; then rm /usr/bin/python; fi && ln -s /usr/bin/python3.6 /usr/bin/python
RUN if [ -f /usr/bin/pip3 ]; then rm /usr/bin/pip3; fi && ln -s /usr/bin/pip3.6 /usr/bin/pip3
RUN if [ -f /usr/bin/pip ]; then rm /usr/bin/pip; fi && ln -s /usr/bin/pip3.6 /usr/bin/pip


# Update APT and install required packages
RUN apt-get update && \
    apt-get install -y libopenmpi-dev libgl1-mesa-dev libx11-dev libxrandr-dev libxi-dev mesa-utils clang cmake freeglut3-dev


# Install Python packages
RUN pip3 install protobuf==3.19.6 tensorflow==1.13.1 PyOpenGL PyOpenGL_accelerate mpi4py numpy

# Set working directory
WORKDIR /workspace

# Clone the repository
RUN git clone https://github.com/xbpeng/DeepMimic.git

RUN /bin/bash -c "cd DeepMimic/DeepMimicCore && ls && source build.sh && make python"