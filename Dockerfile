FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install Python, pip, Git and terminal utilities
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        git \
        curl \
        wget \
        bash \
        sudo \
        nano \
        vim \
        ca-certificates \
        build-essential && \
    rm -rf /var/lib/apt/lists/*

# Create Python virtual environment
RUN python3 -m venv /opt/jupyter

ENV PATH="/opt/jupyter/bin:$PATH"

# Install JupyterLab
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir jupyterlab

# Create Jupyter user
RUN useradd -m -s /bin/bash jupyter && \
    echo "jupyter ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/jupyter

# Create workspace
RUN mkdir -p /home/jupyter/workspace && \
    chown -R jupyter:jupyter /home/jupyter

WORKDIR /home/jupyter/workspace

USER jupyter

# Configure JupyterLab password
RUN jupyter server password --password="muin"

# Render uses the PORT environment variable
EXPOSE 8888

# Start JupyterLab
CMD ["bash", "-c", "jupyter lab --ip=0.0.0.0 --port=${PORT:-8888} --no-browser --ServerApp.allow_remote_access=True --ServerApp.root_dir=/home/jupyter/workspace"]
