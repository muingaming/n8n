FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
        curl \
        ca-certificates \
        gnupg \
        unzip \
        python3 \
        make \
        g++ \
        build-essential \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
        | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \
        > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install -g n8n \
    && curl -fsSL https://localtonet.com/install.sh | sh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# n8n configuration
ENV N8N_HOST=0.0.0.0
ENV N8N_PROTOCOL=http
ENV N8N_SECURE_COOKIE=false

# Render exposes this port automatically.
# Localtonet will tunnel to the same port.
EXPOSE 5678

CMD ["sh", "-c", "\
    echo '========================================'; \
    echo 'Starting n8n + Localtonet'; \
    echo 'Render PORT: ${PORT:-5678}'; \
    echo '========================================'; \
    if [ -z \"$LOCALTONET_TOKEN\" ]; then \
        echo 'ERROR: LOCALTONET_TOKEN environment variable is missing.'; \
        exit 1; \
    fi; \
    n8n start --host 0.0.0.0 --port ${PORT:-5678} & \
    N8N_PID=$!; \
    sleep 10; \
    echo 'Starting Localtonet tunnel...'; \
    localtonet --authtoken \"$LOCALTONET_TOKEN\" & \
    wait $N8N_PID \
"]
