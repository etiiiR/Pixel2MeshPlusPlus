FROM songhesd/cuda:9.0-cudnn7-devel-ubuntu16.04

# Set CUDA paths
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

# Install base packages
RUN apt-get update && apt-get install -y \
    wget \
    git \
    unzip \
    build-essential \
    cmake \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    curl \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    && apt-get clean

# Install Python 3.6 from source
WORKDIR /opt
RUN wget https://www.python.org/ftp/python/3.6.15/Python-3.6.15.tgz && \
    tar -xvf Python-3.6.15.tgz && \
    cd Python-3.6.15 && \
    ./configure --enable-optimizations && \
    make -j8 && \
    make altinstall

# Symlink python and pip
RUN ln -s /usr/local/bin/python3.6 /usr/bin/python && \
    ln -s /usr/local/bin/pip3.6 /usr/bin/pip

# Install Python packages
RUN pip install --upgrade pip && pip install \
    numpy==1.19.5 \
    tflearn==0.3.2 \
    opencv-python==4.1.2.30 \
    pyyaml \
    scipy==1.2.2 \
    tensorflow-gpu==1.12.0

# 🔍 NOW you can safely check for TensorFlow paths (optional debug)
RUN find /usr/local/ -name "tensorflow"

# Set working directory
WORKDIR /workspace

# Clone Pixel2Mesh++ repository
RUN git clone https://github.com/etiiiR/Pixel2MeshPlusPlus
WORKDIR /workspace/Pixel2MeshPlusPlus

# Compile Chamfer Distance CUDA code
WORKDIR /workspace/Pixel2MeshPlusPlus/external
RUN make || echo "⚠️ Chamfer Distance build failed, edit Makefile for your CUDA version if needed."

# Final environment setup
ENV PYTHONPATH="/workspace/Pixel2MeshPlusPlus"

WORKDIR /workspace/Pixel2MeshPlusPlus
CMD ["/bin/bash"]

