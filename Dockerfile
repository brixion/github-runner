FROM myoung34/github-runner:latest

# Update and install base dependencies
RUN apt-get update && apt-get install -y \
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
    pkg-config

# Install Node.js (newer version than what comes with the base image)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Install yarn
RUN npm install -g yarn

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*
