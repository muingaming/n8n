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
