FROM ghcr.io/actions/actions-runner:2.331.0

USER root

# Set shell with pipefail for better error handling
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Update and install base dependencies
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
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
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Add PHP repository and install PHP 8.1, 8.2, 8.3, 8.4, 8.5 and common extensions
RUN add-apt-repository -y ppa:ondrej/php \
 && apt-get update \
 && apt-get install -y --no-install-recommends \

    # PHP 8.1 with common extensions
    php8.1 \
    php8.1-cli \
    php8.1-common \
    php8.1-curl \
    php8.1-gd \
    php8.1-mbstring \
    php8.1-mysqli \
    php8.1-pdo-mysql \
    php8.1-xml \
    php8.1-zip \
    php8.1-bcmath \
    php8.1-opcache \
    php8.1-intl \

    # PHP 8.2 with common extensions
    php8.2 \
    php8.2-cli \
    php8.2-common \
    php8.2-curl \
    php8.2-gd \
    php8.2-mbstring \
    php8.2-mysqli \
    php8.2-pdo-mysql \
    php8.2-xml \
    php8.2-zip \
    php8.2-bcmath \
    php8.2-intl \
    php8.2-opcache \

    # PHP 8.3 with common extensions
    php8.3 \
    php8.3-cli \
    php8.3-common \
    php8.3-curl \
    php8.3-gd \
    php8.3-mbstring \
    php8.3-mysqli \
    php8.3-pdo-mysql \
    php8.3-xml \
    php8.3-zip \
    php8.3-bcmath \
    php8.3-intl \
    php8.3-opcache \

    # PHP 8.4 with common extensions
    php8.4 \
    php8.4-cli \
    php8.4-common \
    php8.4-curl \
    php8.4-gd \
    php8.4-mbstring \
    php8.4-mysqli \
    php8.4-pdo-mysql \
    php8.4-xml \
    php8.4-zip \
    php8.4-bcmath \
    php8.4-intl \
    php8.4-opcache \

    # PHP 8.5 with common extensions
    php8.5 \
    php8.5-cli \
    php8.5-common \
    php8.5-curl \
    php8.5-gd \
    php8.5-mbstring \
    php8.5-mysqli \
    php8.5-pdo-mysql \
    php8.5-xml \
    php8.5-zip \
    php8.5-bcmath \
    php8.5-intl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Configure PHP: Register all PHP versions and set php8.5 as default
RUN update-alternatives --install /usr/bin/php php /usr/bin/php8.1 81 \
 && update-alternatives --install /usr/bin/php php /usr/bin/php8.2 82 \
 && update-alternatives --install /usr/bin/php php /usr/bin/php8.3 83 \
 && update-alternatives --install /usr/bin/php php /usr/bin/php8.4 84 \
 && update-alternatives --install /usr/bin/php php /usr/bin/php8.5 85 \
 && update-alternatives --set php /usr/bin/php8.5

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
 && pip3 install --no-cache-dir --break-system-packages aws-sam-cli

# --- FIX PERMISSIONS ---
# After root has run npm, change ownership of the cache and global install
# directories to the runner user. This is the crucial step.
RUN chown -R runner:runner /home/runner/.npm /home/runner/.npm-global

USER runner
