FROM myoung34/github-runner:latest

# Install Node.js (newer version than what comes with the base image)
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Install npm (you already had this, but keeping it for completeness)
# Install git and other essential build tools
RUN apt-get install -y \
    git \
    git-lfs \
    build-essential \
    python3 \
    python3-pip \
    wget \
    openssh-client \
    rsync \
    zlib1g-dev \
    libcurl4-openssl-dev

# Install yarn
RUN npm install -g yarn

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*
