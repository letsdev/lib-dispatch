FROM ubuntu:bionic-20180224

ENV ANDROID_SDK_HOME="/opt/android-sdk" \
    ANDROID_NDK_VERSION="r16b" \
    #SDK TOOLS 26.0.2 ndk-r16b
    ANDROID_SDK_TOOLS_VERSION="3859397" \
    DEBIAN_FRONTEND="noninteractive"

#Cannot access environment variables in the same time they are defined
ENV PATH="$PATH:$ANDROID_SDK_HOME/tools:$ANDROID_SDK_HOME/tools/bin:$ANDROID_SDK_HOME/platform-tools" \
    ANDROID_NDK_HOME="$ANDROID_SDK_HOME/ndk-bundle" \
    ANDROID_HOME="$ANDROID_SDK_HOME" \
    ANDROID_SDK_ROOT="$ANDROID_SDK_HOME"

#Base
RUN apt-get update \
    && apt-get install -yq \
        build-essential \
        software-properties-common \
        git \
        ninja-build \
        cmake \
        python \
        wget \ 
        unzip \
        clang \
        systemtap-sdt-dev \
        libbsd-dev \
        linux-libc-dev \
        # add java before maven to prevent downloading java 9
        openjdk-8-jre-headless \
        maven \
    && apt-get clean

#Android SDK
RUN echo "************ Installing Android SDK Tools ************" \
    && wget --output-document=sdk-tools.zip \
        "https://dl.google.com/android/repository/sdk-tools-linux-$ANDROID_SDK_TOOLS_VERSION.zip" \
    && mkdir -p "$ANDROID_SDK_HOME" \
    && unzip -q sdk-tools.zip -d "$ANDROID_SDK_HOME" \
#Cleanup
    && rm -f sdk-tools.zip

#The `yes` is for accepting all non-standard tool licenses.
RUN mkdir "$ANDROID_SDK_HOME/.android" \
    && touch "$ANDROID_SDK_HOME/.android/repositories.cfg"

RUN yes | sdkmanager --licenses

#Build Tools
RUN echo "************ Installing Build Tools ************" \
    && sdkmanager 'build-tools;27.0.3'

#C++
RUN echo "************ Installing C++ Support ************" \
    && sdkmanager 'cmake;3.6.4111459' 'ndk-bundle'

RUN useradd -m jenkins -u 112
USER jenkins
RUN mkdir -p 'home/jenkins/.m2'