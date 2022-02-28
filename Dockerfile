FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

## Choose the appropriate PHP and composer versions
## For php 5.6, you can use https://getcomposer.org/download/1.10.25/composer.phar
## See list of composer PHAR URLs in https://getcomposer.org/download/

ARG PHP_VERSION
ARG COMPOSER_PHAR_URL

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server sudo

ADD set_root_pw.sh /set_root_pw.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh
RUN mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config \
  && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
  && touch /root/.Xauthority \
  && true

## Set a default user. Available via runtime flag `--user docker`
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory, but also be able to sudo
RUN useradd docker \
        && passwd -d docker \
        && mkdir /home/docker \
        && chown docker:docker /home/docker \
        && addgroup docker staff \
        && addgroup docker sudo \
        && true


RUN apt-get update \
  && apt-get install --no-install-recommends --yes \
    wget \
    gnupg2 \
    ca-certificates \
    lsb-release \
    apt-transport-https \
    unzip \
  && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
  && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
  && apt-get update \
  && apt-get install --no-install-recommends --yes \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-dom \
    php${PHP_VERSION}-apcu \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-memcached \
    php${PHP_VERSION}-mysqli \
    php${PHP_VERSION}-yaml \
    php${PHP_VERSION}-zip \
  && rm -rf /var/lib/apt/lists/* \
  # install composer
  && wget -O /bin/composer ${COMPOSER_PHAR_URL} \
  && chmod +x /bin/composer

EXPOSE 22
CMD ["/run.sh"]
VOLUME ["/jetpack"]
