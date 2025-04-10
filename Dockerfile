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
    pkg-config \
    yamllint

# Install Node.js (newer version than what comes with the base image)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Install yarn
RUN npm install -g yarn

# Install AWS SAM CLI
RUN pip3 install aws-sam-cli

# Fix permissions for GitHub home directory
RUN mkdir -p /github/home && \
    chmod -R 777 /github

# Create necessary directories for GitHub Actions
RUN mkdir -p /github/workflow && \
    mkdir -p /github/file_commands && \
    chmod -R 777 /github

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure environment for GitHub Actions
ENV RUNNER_TOOL_CACHE=/tmp/runner-tool-cache

# Create tool cache directory with proper permissions
RUN mkdir -p $RUNNER_TOOL_CACHE && \
    chmod -R 777 $RUNNER_TOOL_CACHE
