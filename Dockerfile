FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        curl \
        ca-certificates \
        gnupg \
        python3 \
        make \
        g++ \
        build-essential \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
        | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_26.x nodistro main" \
        > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y nodejs \
    && node --version \
    && npm --version \
    && npm install -g n8n \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV N8N_HOST=0.0.0.0
ENV N8N_PROTOCOL=https
ENV N8N_SECURE_COOKIE=true

EXPOSE 5678

CMD ["sh", "-c", "n8n start --port $PORT"]
