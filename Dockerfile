FROM setupphp/node:latest

USER root

RUN set -ex && apt-get update && apt-get install -y apt-utils ca-certificates curl gnupg iputils-ping libicu-dev sudo --no-install-recommends

# Update and install base dependencies
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
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
    gh \
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

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer \
 && chmod +x /usr/local/bin/composer

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
 && unzip awscliv2.zip \
 && ./aws/install \
 && rm -rf awscliv2.zip aws

# --- CONFIGURE NPM FOR GLOBAL INSTALLS AS NON-ROOT ---
# 1. Create a directory for global packages and set npm to use it
RUN mkdir -p /home/runner/.npm-global \
 && mkdir -p /home/runner/.npm
ENV NPM_CONFIG_PREFIX=/home/runner/.npm-global
# 2. Add the new global bin directory to the PATH
ENV PATH=$NPM_CONFIG_PREFIX/bin:$PATH
# --- END OF NPM CONFIGURATION ---

# Install global npm packages and AWS SAM CLI
RUN npm install -g yarn @redocly/cli typescript \
 && pip3 install --no-cache-dir --break-system-packages --ignore-installed blinker aws-sam-cli

RUN adduser --disabled-password --gecos '' runner \
  && usermod -aG sudo runner \
  && mkdir -m 777 -p /home/runner \
  && sed -i 's/%sudo\s.*/%sudo ALL=(ALL:ALL) NOPASSWD : ALL/g' /etc/sudoers

# --- FIX PERMISSIONS ---
# After root has run npm, change ownership of the cache and global install
# directories to the runner user. This is the crucial step.
RUN chown -R runner:runner /home/runner/.npm /home/runner/.npm-global

USER runner
