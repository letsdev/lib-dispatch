#!/usr/bin/bash

CURRENT_PATH=`pwd`
SDK_VERSION=21
PROJECT_NAME=dispatch
GIT_URL=https://github.com/Fischiii/swift-corelibs-libdispatch.git
GIT_BRANCH=testAndroid

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
build_android() {
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
    -DCMAKE_INSTALL_PREFIX=$LIBS/android/$ABI
    
    ninja
    
    cmake -P cmake_install.cmake
}

build_linux() {
    echo '######################################'
    echo "building linux"
    echo '######################################'

    local SRC_TARGET=$PROJECT_NAME-copy/linux
    if [ ! -d "${SRC_TARGET}" ]; then
        mkdir -p ${SRC_TARGET}
    fi
    
    cp -R $SRC/* $SRC_TARGET
    cd $SRC_TARGET
    
    cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DBUILD_SHARED_LIBS=YES \
    -DENABLE_TESTING=OFF \
    -DCMAKE_INSTALL_PREFIX=$LIBS/linux
    
    ninja
    
    cmake -P cmake_install.cmake
}

# ############################
# build $ABI $ARCH $TOOLCHAIN_NAME
build_android 'arm64-v8a' 'arm64' 'aarch64-linux-android'
build_android 'armeabi-v7a' 'arm' 'arm-linux-androideabi'
build_android 'x86' 'x86' 'i686-linux-android'
build_android 'x86_64' 'x86_64' 'x86_64-linux-android'
build_linux

