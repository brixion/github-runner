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

# --- CONFIGURE NPM FOR GLOBAL INSTALLS AS NON-ROOT ---
# 1. Create a directory for global packages and set npm to use it
RUN mkdir -p /home/runner/.npm-global
ENV NPM_CONFIG_PREFIX=/home/runner/.npm-global
# 2. Add the new global bin directory to the PATH
ENV PATH=$NPM_CONFIG_PREFIX/bin:$PATH
# 3. Give the runner user ownership of this new directory ONLY
RUN chown -R runner:runner /home/runner/.npm-global \
 && mkdir -p /home/runner/.npm \
 && chown -R 1001:1001 /home/runner/.npm
# --- END OF NPM CONFIGURATION ---

# Install global npm packages and AWS SAM CLI
RUN npm install -g yarn @redocly/cli \
 && pip3 install --no-cache-dir aws-sam-cli

USER runner
