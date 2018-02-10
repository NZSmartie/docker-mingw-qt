FROM ubuntu:16.04

LABEL description="LibrePCB debian build environment for Qt 5.10 with MinGW-w64"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qq && apt-get install -qq -y \
    git \
    build-essential \
    libglu1-mesa-dev \
    openssl \
    zlib1g zlib1g-dev \
    autoconf automake autopoint bash bison bzip2 flex gettext \
    git g++ gperf intltool libffi-dev libgdk-pixbuf2.0-dev \
    libtool-bin libltdl-dev libssl-dev libxml-parser-perl make \
    openssl p7zip-full patch perl pkg-config python ruby scons \
    sed unzip wget xz-utils \
    g++-multilib libc6-dev-i386 \
    && rm -rf /var/lib/apt/lists/*

ARG MXE_VERSION=master

RUN cd /opt && git clone https://github.com/mxe/mxe -b ${MXE_VERSION}

# Supported MXE_TARGET values are:
#  i686-w64-mingw32.static
#  i686-w64-mingw32.shared
#  x86_64-w64-mingw32.static
#  x86_64-w64-mingw32.shared

ARG MXE_TARGET=x86_64-w64-mingw32.shared

ARG QT_VERSION=5.10.0
ARG BUILD_JOBS=4

RUN cd /opt/mxe && make qtbase qtbase_VERSION=${QT_VERSION} -j ${BUILD_JOBS} MXE_TARGETS='${MXE_TARGET}'

RUN make clean-junk

ENV PATH /opt/mxe/usr/bin:/opt/mxe/usr/${MXE_TARGET}/qt5/bin:$PATH

# Add group & user 
RUN groupadd -r user && useradd --create-home --gid user user

USER user 
WORKDIR /home/user
ENV HOME /home/user
