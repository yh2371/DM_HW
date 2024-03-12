# Use Ubuntu 20.04 as the base image
FROM ubuntu:22.04

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

RUN apt-get update && \
    apt-get install -y gcc-11 g++-11 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100 --slave /usr/bin/g++ g++ /usr/bin/g++-11

# Install libstdc++-11-dev for iostream support
RUN apt-get install -y libstdc++-11-dev

# Set environment variables for GCC 11
ENV CC=/usr/bin/gcc-11
ENV CXX=/usr/bin/g++-11

# Download and install Miniconda
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    /bin/bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh
# Set environment variables for Conda
ENV PATH="/opt/conda/bin:$PATH"

# Create a new Conda environment with Python 3.6.15 and gcc-11
RUN conda create -n deepmimic python=3.6.13 clangdev && \
    conda install -n deepmimic -c conda-forge gcc_linux-64=11 libcurl libv8 libgcc-ng libgfortran-ng libgfortran4 libglib libstdcxx-ng && \
    conda clean --all --yes

# Activate the Conda environment
SHELL ["/bin/bash", "-c"]
RUN source activate deepmimic

# Set environment variables
ENV CONDA_DEFAULT_ENV=deepmimic
ENV CONDA_PREFIX=/opt/conda/envs/$CONDA_DEFAULT_ENV
ENV PATH=$CONDA_PREFIX/bin:$PATH
ENV LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu/:/lib/x86_64-linux-gnu/:$LD_LIBRARY_PATH"
RUN clang++ -v -E
# Install pthreads
RUN apt-get update && \
    apt-get install -y libpthread-stubs0-dev libopenmpi-dev libxi-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN conda install -n deepmimic tensorflow=1.13.1 && \
    pip install PyOpenGL PyOpenGL_accelerate mpi4py numpy

RUN apt-get update

WORKDIR /workspace
# Set working directory
RUN apt-get install gcc-snapshot -y 

# Clone the repository
RUN git clone https://github.com/yh2371/DM_HW.git



# Build the necessary components
RUN cd DM_HW/DeepMimicCore && \
    source build.sh && \
    make python

# Set entrypoint to run bash
ENTRYPOINT ["bash"]