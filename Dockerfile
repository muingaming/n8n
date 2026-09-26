FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install Python, pip, Git and terminal tools
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
    pip install --no-cache-dir \
        jupyterlab \
        argon2-cffi

# Create Jupyter user
RUN useradd -m -s /bin/bash jupyter && \
    echo "jupyter ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/jupyter

# Create directories
RUN mkdir -p /home/jupyter/workspace \
    /home/jupyter/.jupyter && \
    chown -R jupyter:jupyter /home/jupyter

WORKDIR /home/jupyter/workspace

USER jupyter

# Generate password hash and put it directly into Jupyter config
RUN HASH=$(python3 -c "from jupyter_server.auth import passwd; print(passwd('muin'))") && \
    printf '%s\n' \
    "c.ServerApp.ip = '0.0.0.0'" \
    "c.ServerApp.allow_remote_access = True" \
    "c.ServerApp.root_dir = '/home/jupyter/workspace'" \
    "c.ServerApp.password = '$HASH'" \
    "c.ServerApp.open_browser = False" \
    > /home/jupyter/.jupyter/jupyter_server_config.py

# Render's default port
EXPOSE 10000

# Start JupyterLab
CMD ["bash", "-c", "jupyter lab --ip=0.0.0.0 --port=${PORT:-10000} --no-browser"]
