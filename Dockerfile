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

# Workspace
RUN mkdir -p /workspace

WORKDIR /workspace

# Generate Jupyter password hash for "muin"
RUN HASH=$(python3 -c "from jupyter_server.auth import passwd; print(passwd('muin'))") && \
    mkdir -p /root/.jupyter && \
    printf '%s\n' \
    "c.ServerApp.ip = '0.0.0.0'" \
    "c.ServerApp.allow_remote_access = True" \
    "c.ServerApp.root_dir = '/workspace'" \
    "c.ServerApp.password = '$HASH'" \
    "c.ServerApp.open_browser = False" \
    > /root/.jupyter/jupyter_server_config.py

# Render's port
EXPOSE 10000

# Run JupyterLab as ROOT
CMD ["bash", "-c", "jupyter lab --ip=0.0.0.0 --port=${PORT:-10000} --no-browser --allow-root"]
