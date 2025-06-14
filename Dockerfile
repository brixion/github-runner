# Stage 1: Get the container hooks -> https://github.com/actions/runner/issues/406#issuecomment-2701730334
FROM ghcr.io/alexander-heimbuch/github-runner-container-hooks:latest as runnerContainerHooks

# Stage 2: Main runner image
FROM myoung34/github-runner:latest

# Copy the container hooks from the first stage
COPY --from=runnerContainerHooks /static/runner_container_hooks.js /runner_container_hooks.js

# Create the externals directory that alexander-heimbuch hooks expect
RUN mkdir -p /home/runner/actions-runner/externals \
    && chown -R runner:runner /home/runner/actions-runner/externals

# Set environment variables for container hooks - corrected path for myoung34's actual structure
ENV RUNNER_HOME=/home/runner/actions-runner/
ENV ACTIONS_RUNNER_CONTAINER_HOOKS=/runner_container_hooks.js

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

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*