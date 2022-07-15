FROM debian:11

ENV DEBIAN_FRONTEND noninteractive
ENV USER root
ARG BEEF_USER
ARG BEEF_PASSWORD

RUN echo 'root:root' | chpasswd

# App utils
RUN apt-get update && \
    apt-get install -y apt-utils 2>&1 | grep -v "debconf: delaying package configuration, since apt-utils is not installed"

# Basic Tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    build-essential \
    ca-certificates \
    locales \
    net-tools \
    curl \
    wget \
    git \
    openssl \
    libreadline6-dev \
    zlib1g zlib1g-dev \
    libssl-dev \
    libyaml-dev \
    libsqlite3-0 \
    libsqlite3-dev \
    sqlite3 \
    libxml2-dev \
    libxslt1-dev \
    autoconf \
    libc6-dev \
    libncurses5-dev \
    automake \
    libtool \
    bison

# Set Locale and Timezone
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    dpkg-reconfigure -f noninteractive locales

# Set Timezone
RUN rm /etc/localtime && \
    echo "Asia/Bangkok" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

# Thai fonts
RUN apt-get install -y --no-install-recommends xfonts-thai

RUN apt-get update

# NodeJS
RUN apt-get install -y --no-install-recommends npm && \
    npm install n -g && \
    n lts

# Ruby
RUN apt-get install -y --no-install-recommends ruby ruby-dev ruby-bundler

# BeEF
RUN git clone --depth=1 --recursive https://github.com/beefproject/beef/ /beef && \
    cd beef && \
    bundle install --without test development && \
    ./generate-certificate && \
    sed -i "s/user:   \"beef\"/user: \"beefuser\"/" config.yaml && \
    sed -i "s/passwd: \"beef\"/passwd: \"beefpassword\"/" config.yaml && \
    cd ..
RUN apt remove --purge beef-xss && \
    apt-get install -y --no-install-recommends beef-xss

# Clean up
RUN apt-get clean -y && \
    echo "nameserver 8.8.8.8" > /etc/resolv.conf && \
    rm -rf /var/lib/apt/lists/*

# Turn off swap
RUN swapoff -a