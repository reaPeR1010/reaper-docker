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
    bc binutils-dev bison build-essential ca-certificates ccache clang \
    cmake curl file flex git libelf-dev libncurses5-dev \
    libssl-dev libstdc++-$(apt list libstdc++6 2>/dev/null | grep -Eos '[0-9]+\.[0-9]+\.[0-9]+' | head -1 | cut -d . -f 1)-dev \
    lld make ninja-build python3-dev python3-pip texinfo u-boot-tools xz-utils zlib1g-dev zip zstd lz4 rclone && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/man /usr/share/doc /usr/share/info

ENTRYPOINT ["/bin/bash"]
