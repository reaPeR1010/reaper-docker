FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TZ=Asia/Kolkata

# Install dependencies and configure locale/timezone
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    locales apt-utils tzdata wget software-properties-common \
    bash bc binutils-dev bison build-essential ca-certificates cmake cpio curl default-jre \
    file flex g++ gcc gh git libelf-dev libncurses5-dev libssl-dev \
    libxml2 lz4 make ninja-build python3 python3-dev python3-pip rclone texinfo u-boot-tools \
    xz-utils zlib1g-dev zip zstd && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 && \
    ln -fs /usr/share/zoneinfo/Asia/Kolkata /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Download and extract AOSP Clang
RUN mkdir -p /opt/aosp-clang && \
    curl -L https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/master/clang-r547379.tar.gz \
    -o /tmp/clang.tar.gz && \
    tar -xzf /tmp/clang.tar.gz -C /opt/aosp-clang && \
    rm /tmp/clang.tar.gz

RUN rm -rf /opt/aosp-clang/include \
           /opt/aosp-clang/share \
           /opt/aosp-clang/libexec \
           /opt/aosp-clang/python3* \
           /opt/aosp-clang/runtimes_ndk_cxx \
           /opt/aosp-clang/musl \
           /opt/aosp-clang/prebuilt_include \
           /opt/aosp-clang/android_libc++ && \
    rm -f /opt/aosp-clang/lib/*.a /opt/aosp-clang/lib/*.la && \
    rm -f /opt/aosp-clang/*.txt \
          /opt/aosp-clang/*.bazel \
          /opt/aosp-clang/*INFO \
          /opt/aosp-clang/*LICENSE* \
          /opt/aosp-clang/*.json \
          /opt/aosp-clang/*.py \
          /opt/aosp-clang/*.pyo \
          /opt/aosp-clang/*.pyc \
          /opt/aosp-clang/*.pdb \
          /opt/aosp-clang/*test* \
          /opt/aosp-clang/NOTICE \
          /opt/aosp-clang/.gitattributes && \
    find /opt/aosp-clang -type f -exec file {} \; | \
    grep 'ELF' | grep 'not stripped' | cut -d: -f1 | \
    xargs -r /opt/aosp-clang/bin/llvm-strip --strip-all

ENV PATH="/opt/aosp-clang/bin:$PATH"

# Install ccache
RUN git clone https://github.com/ccache/ccache && \
    cd ccache && mkdir build && cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build . --target install -j$(nproc) && \
    cd ../.. && rm -rf ccache

# Final cleanup to reduce image size
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/man/* /usr/share/doc/* /usr/share/info/* /tmp/*

ENTRYPOINT ["/bin/bash"]
