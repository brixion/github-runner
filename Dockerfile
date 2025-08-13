FROM ghcr.io/actions/actions-runner:latest

USER root

# Update and install base dependencies
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
 && apt update \
 && apt install -y --no-install-recommends \
    # System build tools
    autoconf \
    automake \
    build-essential \
    libcurl4-openssl-dev \
    libonig-dev \
    libssl-dev \
    libtool \
    libxml2-dev \
    libzip-dev \
    m4 \
    pkg-config \
    zlib1g-dev \
    # Git
    git \
    git-lfs \
    # Node.js (installed via nodesource script)
    nodejs \
    # Python
    python3 \
    python3-pip \
    # General utilities
    curl \
    openssh-client \
    rsync \
    software-properties-common \
    unzip \
    wget \
    zip \
    # Linters/Formatters
    yamllint \
 && apt clean \
 && rm -rf /var/lib/apt/lists/*

# Install global npm packages and AWS SAM CLI
RUN npm install -g yarn @redocly/cli \
 && pip3 install --no-cache-dir aws-sam-cli

# Give correct permissions to user runner
RUN chown -R runner:runner /usr/lib \
 && chown -R runner:runner /usr/bin \
 && chown -R 0:0 /usr/bin/sudo \

USER runner
