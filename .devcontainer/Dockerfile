FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Outils pour construire les paquets .deb (packages/)
RUN apt-get update && apt-get install -y --no-install-recommends \
    fakeroot \
    dpkg-dev \
  && rm -rf /var/lib/apt/lists/*

