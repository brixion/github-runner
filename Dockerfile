FROM ghcr.io/actions/actions-runner:latest

# Install Node.js (newer version than what comes with the base image)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

# Update and install base dependencies
RUN apt update \
 && apt install -y --no-install-recommends \
    software-properties-common \
    curl \
    wget \
    git \
    git-lfs \
    unzip \
    zip \
    build-essential \
    autoconf \
    automake \
    libtool \
    m4 \
    python3 \
    python3-pip \
    openssh-client \
    rsync \
    zlib1g-dev \
    libxml2-dev \
    libssl-dev \
    libonig-dev \
    libzip-dev \
    libcurl4-openssl-dev \
    pkg-config \
    yamllint \
    nodejs \
 && apt clean \
 && rm -rf /var/lib/apt/lists/*

# Install yarn
RUN npm install -g yarn

# Install AWS SAM CLI
RUN pip3 install aws-sam-cli
