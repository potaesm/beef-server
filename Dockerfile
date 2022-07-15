FROM debian:11

ENV DEBIAN_FRONTEND noninteractive
ENV USER root
ENV TERM xterm

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
    gnupg2 \
    libcurl4-openssl-dev \
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
    bison \
    sudo

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
# RUN apt-get install -y --no-install-recommends ruby ruby-dev ruby-bundler
RUN curl -sSL https://rvm.io/mpapis.asc | sudo gpg2 --import - && \
    curl -sSL https://rvm.io/pkuczynski.asc | sudo gpg2 --import - && \
    curl -sSL https://get.rvm.io | sudo bash -s stable
RUN . /etc/profile.d/rvm.sh && \
    rvm requirements && \
    rvm install 2.7 && \
    rvm use 2.7 --default
RUN git clone --depth=1 --recursive https://github.com/rubygems/rubygems.git /rubygems && \
    cd rubygems && \
    ruby setup.rb
RUN gem install bundler

# BeEF
RUN git clone --depth=1 --recursive https://github.com/beefproject/beef.git /beef && \
    cd beef && \
    bundle install && \
    ./generate-certificate && \
    sed -i "s/# public:/public:/" config.yaml && \
    sed -i "s/#     host: \"\" # public hostname/IP address/    host: \"beef-tool.herokuapp.com\" # public hostname/IP address/" config.yaml && \
    sed -i "s/#     https: false # true/false:/    https: true # true/false/" config.yaml && \
    sed -i "s/user:   \"beef\"/user: \"beefuser\"/" config.yaml && \
    sed -i "s/passwd: \"beef\"/passwd: \"beefpassword\"/" config.yaml && \
    cd ..

# Clean up
RUN apt-get clean -y && \
    echo "nameserver 8.8.8.8" > /etc/resolv.conf && \
    rm -rf /var/lib/apt/lists/*

# Turn off swap
RUN swapoff -a