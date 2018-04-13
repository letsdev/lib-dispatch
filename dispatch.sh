#!/usr/bin/bash

CURRENT_PATH=`pwd`
SDK_VERSION=21
PROJECT_NAME=dispatch
GIT_URL=https://github.com/ephemer/swift-corelibs-libdispatch.git
GIT_BRANCH=fixAndroidBuild

SRC="${CURRENT_PATH}/${PROJECT_NAME}-src"
LIBS="${CURRENT_PATH}/libs"

if [ ! -d "${ANDROID_NDK_HOME}" ]; then
    echo "ANDROID_NDK_HOME not defined or directory does not exist"
    exit 1
fi

if [ -d "${SRC}" ]; then
    rm -dfR $SRC
    mkdir $SRC
fi

# ############################
git clone ${GIT_URL} --branch ${GIT_BRANCH} ${SRC}

# ############################
build() {
    if [ -z $1 ]; then
        echo 'no ABI set'
        exit 1
    elif [ -z $2 ]; then
        echo 'no ARCH set'
        exit 1
    elif [ -z $3 ]; then
        echo 'no toolchain name set'
        exit 1
    fi
    
    local ABI=$1
    local ARCH=$2
    local TOOL_NAME=$3

    echo '######################################'
    echo "building android ${ABI}"
    echo '######################################'

    local TOOLCHAIN_ROOT_PATH=$CURRENT_PATH/toolchains/${TOOL_NAME}
    local TOOLCHAIN_PATH=$TOOLCHAIN_ROOT_PATH/bin
    local NDK_TOOLCHAIN_BASENAME=$TOOLCHAIN_PATH/$TOOL_NAME
    
    if [ -d $TOOLCHAIN_PATH ]; then
        echo "toolchain exists"
    else
        echo "toolchain missing, create it"
        $ANDROID_NDK_HOME/build/tools/make-standalone-toolchain.sh \
        --platform=android-$SDK_VERSION \
        --arch=$ARCH \
        --stl=libc++ \
        --install-dir=$TOOLCHAIN_ROOT_PATH --verbose
    fi
    
    export CC=$NDK_TOOLCHAIN_BASENAME-gcc
    export CXX=$NDK_TOOLCHAIN_BASENAME-g++
    export LD=$NDK_TOOLCHAIN_BASENAME-ld
    export AR=$NDK_TOOLCHAIN_BASENAME-ar
    export AS=$NDK_TOOLCHAIN_BASENAME-clang
    export RANLIB=$NDK_TOOLCHAIN_BASENAME-ranlib
    export STRIP=$NDK_TOOLCHAIN_BASENAME-strip
    
    local SRC_TARGET=$PROJECT_NAME-copy/$ABI
    if [ ! -d "${SRC_TARGET}" ]; then
        mkdir -p ${SRC_TARGET}
    fi

    cp -R $SRC/* $SRC_TARGET
    cd $SRC_TARGET
    
   cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_NAME=Android \
    -DCMAKE_SYSROOT=$TOOLCHAIN_ROOT_PATH/sysroot \
    -DBUILD_SHARED_LIBS=YES \
    -DENABLE_TESTING=OFF \
    -DCMAKE_ANDROID_ARCH_ABI=$ABI \
    -DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=clang \
    -DCMAKE_INSTALL_PREFIX=$LIBS/$ABI
    
    ninja

    cmake -P cmake_install.cmake
}

# ############################
# build $ABI $ARCH $TOOLCHAIN_NAME
build 'arm64-v8a' 'arm64' 'aarch64-linux-android'
build 'armeabi-v7a' 'arm' 'arm-linux-androideabi'
build 'x86' 'x86' 'i686-linux-android'
build 'x86_64' 'x86_64' 'x86_64-linux-android'
