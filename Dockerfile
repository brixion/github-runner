FROM ghcr.io/actions/actions-runner:2.333.1
ARG PHP_VERSION=all
ENV PHP_VERSION_ALL="8.1 8.2 8.3 8.4 8.5"
ENV PHP_VERSION_DEFAULT="8.5"

USER root

# Set shell with pipefail for better error handling
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN usermod -aG sudo runner \
  && mkdir -p /home/runner \
  && chmod 777 /home/runner \
  && sed -i 's/%sudo\s.*/%sudo ALL=(ALL:ALL) NOPASSWD : ALL/g' /etc/sudoers

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

# --- FIX PERMISSIONS ---
# After root has run npm, change ownership of the cache and global install
# directories to the runner user. This is the crucial step.
RUN chown -R runner:runner /home/runner/.npm /home/runner/.npm-global

USER runner

RUN set -ex \
  && SUDO=sudo \
  && PHP_VERSIONS="$PHP_VERSION_ALL" \
  && DEFAULT_PHP_VERSION="$PHP_VERSION_DEFAULT" \
  && if [ "${PHP_VERSION:-all}" != "all" ]; then \
       PHP_VERSIONS="$PHP_VERSION"; \
       DEFAULT_PHP_VERSION="$PHP_VERSION"; \
     fi \
      && savedAptMark="$($SUDO apt-mark showmanual)" \
      && $SUDO apt-mark auto '.*' > /dev/null \
      && $SUDO apt-get update && $SUDO apt-get install -y --no-install-recommends curl file gnupg jq lsb-release mysql-server postgresql unzip \
      && $SUDO usermod -d /var/lib/mysql/ mysql \
      && $SUDO add-apt-repository -y ppa:git-core/ppa \
      && $SUDO add-apt-repository -y ppa:ondrej/php \
      && $SUDO add-apt-repository -y ppa:ondrej/apache2 \
      && $SUDO install -m 0755 -d /etc/apt/keyrings \
      && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
      && $SUDO chmod a+r /etc/apt/keyrings/docker.gpg \
      && echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" | $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null \
      && $SUDO apt-get update \
      && $SUDO cp -r /etc/apt/sources.list.d /etc/apt/sources.list.d.save \
      && for v in $PHP_VERSIONS; do \
           $SUDO apt-get install -y --no-install-recommends php"$v" \
           php"$v"-dev \
           php"$v"-curl \
           php"$v"-mbstring \
           php"$v"-xml \
           php"$v"-intl \
           php"$v"-mysql \
           php"$v"-pgsql \
           php"$v"-zip; \
         done \
      && $SUDO curl -o /usr/bin/systemctl -sL https://raw.githubusercontent.com/shivammathur/node-docker/main/systemctl-shim \
      && $SUDO chmod a+x /usr/bin/systemctl \
      && $SUDO curl -o /usr/lib/ssl/cert.pem -sL https://curl.se/ca/cacert.pem \
      && curl -o /tmp/pear.phar -sL https://raw.githubusercontent.com/pear/pearweb_phars/master/install-pear-nozlib.phar \
      && php /tmp/pear.phar && rm -f /tmp/pear.phar \
    && $SUDO apt-get install -y --no-install-recommends autoconf automake gcc g++ git \
    && $SUDO apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    && for v in $PHP_VERSIONS; do \
        $SUDO apt-get install -y --no-install-recommends php"$v"-xdebug 2>/dev/null || ($SUDO spc -p "$v" -e xdebug-xdebug/xdebug@master -r verbose) \
      && $SUDO apt-get install -y --no-install-recommends php"$v"-imagick 2>/dev/null || (IMAGICK_LIBS=libmagickwand-dev $SUDO spc -p "$v" -e imagick-imagick/imagick@master -r verbose); \
      done \
    && for tool in php phar phar.phar php-cgi php-config phpize phpdbg; do \
        { [ -e /usr/bin/"$tool""$DEFAULT_PHP_VERSION" ] && $SUDO update-alternatives --set $tool /usr/bin/"$tool""$DEFAULT_PHP_VERSION" || true; } \
      done \
      && $SUDO rm -rf /var/lib/apt/lists/* /tmp/* /var/cache/* /usr/share/doc/* /usr/share/man/* \
      && { [ -z "$savedAptMark" ] || echo "$savedAptMark" | xargs -r $SUDO apt-mark manual > /dev/null; } \
      && $SUDO find /usr/local -type f -executable -exec ldd '{}' ';' \
        | awk '/=>/ { print $(NF-1) }' \
        | sort -u \
        | xargs -r dpkg-query --search \
        | cut -d: -f1 \
        | sort -u \
        | xargs -r $SUDO apt-mark manual \
      && $SUDO apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
      # smoke test
      && gcc --version \
      && g++ --version \
      && git --version \
      && docker --version \
      && for v in $PHP_VERSIONS; do \
           php"$v" -v; \
         done \
      && php -v

USER root

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer \
 && chmod +x /usr/local/bin/composer

# Install global PHP QA tools needed by workflows that don't run composer install.
# (php-cs-fixer and phpcs are invoked directly in lint workflows.)
RUN curl -fsSL https://cs.symfony.com/download/php-cs-fixer-v3.phar -o /usr/local/bin/php-cs-fixer \
 && chmod +x /usr/local/bin/php-cs-fixer \
 && mkdir -p /opt/composer \
 && COMPOSER_HOME=/opt/composer composer global require --no-interaction --no-progress squizlabs/php_codesniffer:^3 phpstan/phpstan:^2 \
 && ln -sf /opt/composer/vendor/bin/phpcs /usr/local/bin/phpcs \
 && ln -sf /opt/composer/vendor/bin/phpcbf /usr/local/bin/phpcbf \
 && ln -sf /opt/composer/vendor/bin/phpstan /usr/local/bin/phpstan

USER runner
