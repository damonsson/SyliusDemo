# Use the official FrankenPHP image
FROM dunglas/frankenphp:1-php8.3

WORKDIR /app

VOLUME /app/var/

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    acl \
    file \
    gettext \
    git \
    curl \
    gnupg \
    wkhtmltopdf \
    && ln -s /usr/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf \
    && curl -fsSL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh \
    && bash nodesource_setup.sh \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN set -eux; \
    install-php-extensions \
        @composer \
        apcu \
        intl \
        opcache \
        zip \
        exif \
        gd \
        pdo \
        pdo_mysql

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn && \
    rm -rf /var/lib/apt/lists/*

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PHP_INI_SCAN_DIR=":$PHP_INI_DIR/app.conf.d"

# Copy application-specific PHP and Caddy configuration
COPY --link .docker/php.ini $PHP_INI_DIR/app.conf.d/10-app.ini
COPY --link .docker/Caddyfile /etc/caddy/Caddyfile

# Install Composer dependencies
COPY --link composer.* symfony.* ./

# Copy the rest of the application
COPY --link . ./
RUN rm -Rf frankenphp/

# Healthcheck for the container
HEALTHCHECK --start-period=60s CMD curl -f http://localhost:2019/metrics || exit 1

# Start FrankenPHP with Caddy
CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
