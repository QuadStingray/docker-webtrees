# syntax=docker/dockerfile:1

ARG PHP_VERSION="8.5.13"
ARG COMPOSER_VERSION="2.11.2"

########################################################################
# Stage 1: download webtrees and patch vulnerable PHP dependencies
########################################################################
FROM composer:${COMPOSER_VERSION} AS source

ARG WEBTREES_VERSION="2.2.6"

# Third-party PHP libraries bundled with webtrees that have known security
# advisories. They are raised to the patched releases (same major version).
ARG COMPOSER_SECURITY_UPDATES="\
    guzzlehttp/guzzle:^7.15.2 \
    guzzlehttp/psr7:^2.12.3 \
    league/commonmark:^2.10.2 \
    league/flysystem:^3.35.3 \
    symfony/cache:^7.4.12 \
    symfony/mailer:^7.4.12 \
    symfony/mime:^7.4.12 \
    symfony/polyfill-intl-idn:^1.38.1"

WORKDIR /build

ADD https://github.com/fisharebest/webtrees/releases/download/${WEBTREES_VERSION}/webtrees-${WEBTREES_VERSION}.zip webtrees.zip
ADD https://raw.githubusercontent.com/fisharebest/webtrees/${WEBTREES_VERSION}/composer.json src/composer.json
ADD https://raw.githubusercontent.com/fisharebest/webtrees/${WEBTREES_VERSION}/composer.lock src/composer.lock

RUN set -eux; \
    unzip -q webtrees.zip; \
    cd src; \
    composer require --no-update --no-interaction ${COMPOSER_SECURITY_UPDATES}; \
    packages="$(for p in ${COMPOSER_SECURITY_UPDATES}; do printf '%s ' "${p%%:*}"; done)"; \
    composer update ${packages} --with-all-dependencies --no-dev --no-interaction \
        --no-install --no-scripts --no-plugins --ignore-platform-req='ext-*'; \
    # composer.json uses a classmap/psr-4 autoloader pointing to app/, so build
    # the autoloader inside the webtrees tree itself
    cp composer.json composer.lock ../webtrees/; \
    cd ../webtrees; \
    rm -rf vendor; \
    composer install --no-dev --no-interaction --no-scripts --no-plugins \
        --ignore-platform-req='ext-*' --optimize-autoloader; \
    # same workaround as in the upstream release build (composer webtrees:build)
    echo "<?php require __DIR__ . '/../../conditionable/Traits/Conditionable.php';" \
        > vendor/illuminate/support/Traits/Conditionable.php; \
    composer show --no-dev | grep -E 'guzzle|commonmark|flysystem |symfony/(cache|mailer|mime|polyfill-intl-idn) '; \
    rm -f composer.json composer.lock

########################################################################
# Stage 2: runtime image
########################################################################
FROM php:${PHP_VERSION}-apache-trixie

LABEL maintainer="QuadStingray <docker-webtrees@quadstingray.com>"

ARG WEBTREES_VERSION="2.2.6"
ENV WEBTREES_VERION="${WEBTREES_VERSION}" \
    WEBTREES_VERSION="${WEBTREES_VERSION}"

ENV PHP_MAX_EXECUTION_TIME="80" \
    PHP_POST_MAX_SIZE="265M" \
    PHP_UPLOAD_MAX_FILESIZE="265M" \
    PHP_OTHER_CONFIG=""

# - pull all Debian security updates (apache2, zlib, brotli, apt, ...)
# - build the PHP extensions
# - remove every -dev package and the compiler again, keep only the runtime libs
#   the compiled extensions link against (pattern from the official php image)
RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libzip-dev \
        libicu-dev \
        libpq-dev \
        libmagickwand-dev \
    ; \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp; \
    docker-php-ext-install -j"$(nproc)" pdo_mysql gd zip intl pdo_pgsql pgsql exif; \
    pecl install imagick; \
    docker-php-ext-enable imagick; \
    rm -rf /tmp/pear ~/.pearrc; \
    \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; \
    # compiler toolchain of the base image is not needed at runtime
    apt-mark auto $PHPIZE_DEPS libc6-dev > /dev/null; \
    find /usr/local -type f -name '*.so' -exec ldd '{}' ';' \
        | awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); printf "*%s\n", so }' \
        | sort -u \
        | xargs -r dpkg-query --search \
        | cut -d: -f1 \
        | sort -u \
        | xargs -r apt-mark manual \
    ; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*; \
    \
    php -m | grep -qiE '^imagick$'; \
    php -m | grep -qiE '^gd$'; \
    php -m | grep -qiE '^intl$'; \
    php -m | grep -qiE '^pdo_pgsql$'; \
    php -m | grep -qiE '^pdo_mysql$'; \
    php -m | grep -qiE '^zip$'; \
    if dpkg -l | awk '$1 == "ii" { print $2 }' | grep -E -- '-dev(:|$)'; then echo "dev packages left in image" >&2; exit 1; fi

# basic hardening: hide versions, no directory listings
RUN set -eux; \
    { \
      echo 'ServerTokens Prod'; \
      echo 'ServerSignature Off'; \
      echo 'TraceEnable Off'; \
      echo '<Directory /var/www/>'; \
      echo '    Options -Indexes +FollowSymLinks'; \
      echo '</Directory>'; \
    } > /etc/apache2/conf-available/zz-hardening.conf; \
    a2enconf zz-hardening; \
    echo 'expose_php = Off' > "$PHP_INI_DIR/conf.d/zz-hardening.ini"

# Application code belongs to root and is read-only for the web server.
# Only data/ (and modules_v4/ for custom modules) is writable for www-data.
COPY --from=source --chown=root:root /build/webtrees/ /var/www/html/
RUN set -eux; \
    mkdir -p /usr/local/tome; \
    chown root:root /var/www/html; \
    find /var/www/html -type d -exec chmod 755 {} +; \
    find /var/www/html -type f -exec chmod 644 {} +; \
    chown -R www-data:www-data /var/www/html/data /var/www/html/modules_v4; \
    chmod -R u+rwX,g+rwX,o-w /var/www/html/data /var/www/html/modules_v4

COPY --chmod=755 scripts/ /scripts/

WORKDIR /var/www/html

EXPOSE 80

ENTRYPOINT ["/scripts/entrypoint.sh"]
