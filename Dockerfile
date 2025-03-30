FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TZ=Asia/Kolkata

RUN apt-get update -qq && \
    apt-get install -y -qq locales apt-utils tzdata wget software-properties-common && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 && \
    ln -fs /usr/share/zoneinfo/Asia/Kolkata /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get install -y -qq \
    bash bc binutils-dev bison build-essential ca-certificates cmake cpio curl default-jre \
    file flex g++ gcc gh git libelf-dev libncurses5-dev libssl-dev \
    libstdc++-$(apt list libstdc++6 2>/dev/null | grep -Eos '[0-9]+\.[0-9]+\.[0-9]+' | head -1 | cut -d . -f 1)-dev \
    libxml2 lz4 make ninja-build python3 python3-dev python3-pip rclone texinfo u-boot-tools xz-utils zlib1g-dev zip zstd

RUN wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh all && \
    rm llvm.sh

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/man /usr/share/doc /usr/share/info

RUN git clone https://github.com/ccache/ccache && \
    cd ccache && mkdir build && cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release .. && \
    make CC="gcc" CXX="g++" \
    CFLAGS="-flto -O3 -pipe -ffunction-sections -fdata-sections" \
    CXXFLAGS="-flto -O3 -pipe -ffunction-sections -fdata-sections" && \
    make install && \
    cd ../.. && rm -rf ccache
    
ENTRYPOINT ["/bin/bash"]
