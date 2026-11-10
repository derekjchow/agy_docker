# syntax=docker/dockerfile:1
FROM ubuntu:24.04

LABEL org.opencontainers.image.title="Antigravity CLI (agy)" \
      org.opencontainers.image.description="Ubuntu 24.04 layer with Google Antigravity CLI (agy) installed and persistent .gemini volume"

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/root \
    PATH="/usr/local/bin:/root/.local/bin:${PATH}"

# Install core runtime dependencies required by agy and common workflows
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Cache-busting build arg so scheduled CI builds pick up new agy releases
ARG AGY_VERSION=latest

# Install agy into /usr/local/bin and clean up any build-time state/logs
RUN curl -fsSL https://antigravity.google/cli/install.sh | bash -s -- --dir /usr/local/bin \
    && rm -rf /root/.cache/antigravity /root/.gemini \
    && mkdir -p /root/.gemini /workspace

# Persist credentials, settings, and conversation state across container runs
VOLUME ["/root/.gemini"]

WORKDIR /workspace

CMD ["agy"]
