#!/bin/sh

sudo apt update
sudo apt dist-upgrade -y
sudo apt install -y nano locales dialog apt-utils

# timezone
echo "Europe/Paris" | sudo tee /etc/timezone
sudo rm /etc/localtime
sudo ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime
sudo dpkg-reconfigure -f noninteractive tzdata

# locales (needed for PostgreSQL)
sed -i "s/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen fr_FR.UTF-8
sudo update-locale LANG=fr_FR.UTF-8
sudo dpkg-reconfigure --frontend=noninteractive locales
sudo export LANG="fr_FR.UTF-8"
sudo export LANGUAGE="fr_FR.UTF-8"
sudo export LC_ALL="fr_FR.UTF-8"

# PostgreSQL
# INSTALL FIRST WITH BUSTER !
#sudo apt install -f -y -t buster postgresql-11 postgresql-11-postgis-2.5 --fix-missing
sudo apt install -f -y postgresql-11 postgresql-11-postgis-2.5 --fix-missing

# Needed for QGIS
#sudo echo "deb    http://http.debian.net/debian sid main " > /etc/apt/sources.list.d/sid.list
sudo echo "deb http://deb.debian.org/debian/ buster-backports main contrib non-free" > /etc/apt/sources.list.d/buster-backports.list

# Other packages
sudo apt update
sudo apt install -y -t buster-backports -y --fix-missing \
    wget \
    curl \
    nano \
    git \
    unzip \
    build-essential \
    apt-utils \
    software-properties-common \
    php7.3 php7.3-fpm php7.3-cli php7.3-mysql php7.3-gd php7.3-imagick php7.3-tidy php7.3-xmlrpc php7.3-cgi php7.3-sqlite3 php7.3-curl \
    php7.3-bcmath php7.3-dev php7.3-common php7.3-json php7.3-opcache php7.3-readline php7.3-mbstring php7.3-zip php7.3-pgsql php7.3-intl php7.3-xml \
    php7.3-redis \
    libfcgi-dev libfcgi0ldbl libjpeg62-turbo-dev libmcrypt-dev libssl-dev libc-client2007e libc-client2007e-dev libxml2-dev libbz2-dev libcurl4-openssl-dev \
    libjpeg-dev libpng-dev libfreetype6-dev libkrb5-dev libpq-dev libxml2-dev libxslt1-dev libffi-dev \
    libc6-dev-arm64-cross libc6-dev-armhf-cross \
    nginx \
    python-simplejson \
    python3-pip \
    python-setuptools \
    python3-dev \
    python3-qgis \
    python3-wheel \
    python3-lxml \
    python3-zmq \
    python3-jsonschema \
    python3-dateutil \
    python3-psutil \
    python3-redis \
    qgis-server \
    xvfb \
    libzmq5 \
    redis-server \
    lftp \
    pure-ftpd pure-ftpd-common \
    make \
    gosu
    #supervisor

