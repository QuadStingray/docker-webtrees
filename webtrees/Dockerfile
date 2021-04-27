FROM php:7.4.11-apache

ENV WEBTREES_VERION="2.0.15"

WORKDIR /tmp_download

ADD https://github.com/fisharebest/webtrees/releases/download/${WEBTREES_VERION}/webtrees-${WEBTREES_VERION}.zip .

ADD scripts /scripts

RUN apt-get update
RUN apt-get install -y \
       libfreetype6-dev \
       libjpeg62-turbo-dev \
       libpng-dev \
       libzip-dev \
       libicu-dev \
       unzip \
       libpq-dev

# The following two statements enable ImageMagick
RUN apt-get upgrade -y
RUN apt-get install -y libmagickwand-dev --no-install-recommends && \
    pecl install imagick && docker-php-ext-enable imagick

RUN docker-php-ext-configure gd
RUN docker-php-ext-configure zip
RUN docker-php-ext-configure intl
RUN docker-php-ext-configure pdo_mysql
RUN docker-php-ext-configure pdo_pgsql
RUN docker-php-ext-configure pgsql
RUN docker-php-ext-install -j$(nproc) pdo_mysql gd zip intl pdo_pgsql pgsql exif
RUN unzip webtrees-${WEBTREES_VERION}.zip
RUN mkdir /usr/local/tome
RUN rm -rf /var/www/html
RUN mkdir /var/www/html
RUN cp -r webtrees/* /var/www/html
RUN chmod -R 777 /var/www/html
RUN rm -rf /tmp_download
RUN apt-get -y remove unzip
RUN apt-get -y autoremove
RUN rm -rf /var/lib/apt/lists/*

FROM scratch
MAINTAINER QuadStingray <docker-webtrees@quadstingray.com>

ENV PHP_MAX_EXECUTION_TIME="80"
ENV PHP_POST_MAX_SIZE="265M"
ENV PHP_UPLOAD_MAX_FILESIZE="265M"
ENV PHP_OTHER_CONFIG=""

COPY --from=0 / /

WORKDIR /var/www/html

EXPOSE 80

ENTRYPOINT ["/scripts/entrypoint.sh"]
