FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TZ=Asia/Kolkata

RUN apt-get update -qq && \
    apt-get install -y -qq locales apt-utils tzdata && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 && \
    ln -fs /usr/share/zoneinfo/Asia/Kolkata /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get install -y -qq \
    build-essential binutils-dev clang lld gcc g++ make git curl wget tar zip gzip \
    zlib1g-dev libssl-dev libncurses5-dev flex bison zstd lz4 rclone \
    python3-dev python3-pip libelf-dev bc \
    ca-certificates file lsb-release && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/man /usr/share/doc /usr/share/info

ENTRYPOINT ["/bin/bash"]
