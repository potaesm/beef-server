FROM debian:11

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
# ENV LANG en_US.UTF-8
# ENV LANGUAGE en_US.UTF-8
# ENV LC_ALL en_US.UTF-8
ENV USER root
ENV TERM xterm
ARG PORT

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
    # locales \
    net-tools \
    curl \
    wget \
    git \
    openssl \
    gnupg2 \
    procps \
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
# RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
#     echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
#     echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
#     dpkg-reconfigure -f noninteractive locales

# Set Timezone
# RUN rm /etc/localtime && \
#     echo "Asia/Bangkok" > /etc/timezone && \
#     dpkg-reconfigure -f noninteractive tzdata

# Thai fonts
# RUN apt-get install -y --no-install-recommends xfonts-thai

# RUN apt-get update

# NodeJS
RUN apt-get install -y --no-install-recommends npm && \
    npm install n -g && \
    n lts

# Clean up
RUN apt-get clean -y && \
    echo "nameserver 1.1.1.1" > /etc/resolv.conf && \
    rm -rf /var/lib/apt/lists/*

# Ruby
RUN curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
RUN curl -sSL https://get.rvm.io | bash -s
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install 2.7.4 && rvm use 2.7.4 --default && gem install bundler"

# BeEF
RUN /bin/bash -l -c "git clone --depth=1 --recursive https://github.com/beefproject/beef.git /beef && cd beef && bundle install --without test development && ./generate-certificate && cd .."
RUN cd beef && \
    sed -i "s/allow_reverse_proxy: false/allow_reverse_proxy: true/" config.yaml && \
    sed -i "s/allow_cors: false/allow_cors: true/" config.yaml && \
    sed -i "s/cors_allowed_domains: \"http:\/\/browserhacker.com\"/cors_allowed_domains: \"https:\/\/beef-tool.herokuapp.com\"/" config.yaml && \
    sed -i "s/# public:/public:/" config.yaml && \
    sed -i "s/#     host: \"\"/     host: \"beef-tool.herokuapp.com\"/" config.yaml && \
    sed -i "s/#     https: false/     https: true/" config.yaml && \
    sed -i "s/user:   \"beef\"/user: \"potaesm\"/" config.yaml && \
    sed -i "s/passwd: \"beef\"/passwd: \"aabbccdd\"/" config.yaml && \
    cd ..

# Turn off swap
RUN swapoff -a

# Enable Heroku exec
# RUN rm /bin/sh && ln -s /bin/bash /bin/sh

CMD ["bash", "-l", "-c", "cd /beef && exec ./beef -p $PORT"]

EXPOSE ${PORT}