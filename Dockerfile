FROM ubuntu:16.04
LABEL maintainer "Ligboy.Liu <ligboy@gmail.com>"

ENV ANDROID_HOME /opt/android-sdk
ENV ANDROID_NDK_HOME /opt/android-sdk/ndk-bundle

# Environments
# - Language
RUN locale-gen en_US.UTF-8
ENV LANG "en_US.UTF-8"
ENV LANGUAGE "en_US.UTF-8"
ENV LC_ALL "en_US.UTF-8"

# ------------------------------------------------------
# --- Base pre-installed tools
RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq && apt-get install -y --no-install-recommends \
    curl \
    debconf-utils \
    git \
    mercurial \
    python \
    python-software-properties \
    sudo \
    software-properties-common \
    tree \
    unzip \
    wget \
    zip

# ------------------------------------------------------
# --- SSH config
RUN mkdir -p /root/.ssh
COPY ./ssh/config /root/.ssh/config

# ------------------------------------------------------
# --- Git config
RUN git config --global user.email robot@meitu.com
RUN git config --global user.name "Meitu Robot"

# ------------------------------------------------------
# --- Android Debug Keystore
#RUN mkdir -p /root/.android
#COPY ./android/debug.keystore /root/.android/debug.keystore

# Dependencies to execute Android builds
RUN dpkg --add-architecture i386
RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq && apt-get install -y --no-install-recommends \
    libc6:i386 \
    libgcc1:i386 \
    libncurses5:i386 \
    libstdc++6:i386 \
    libz1:i386

## Open JDK
#RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq && apt-get install -y openjdk-8-jdk
## Oracle JDK
RUN add-apt-repository -y ppa:webupd8team/java && apt-get update -qq
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | /usr/bin/debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq && apt-get install -y --no-install-recommends \
    oracle-java8-installer \
    oracle-java8-set-default

# ------------------------------------------------------
# --- Download Android SDK tools into $ANDROID_HOME

#RUN cd /opt && wget -q https://dl.google.com/android/repository/tools_r25.2.5-linux.zip -O android-sdk-tools.zip
# sdk-tools-linux-3773319.zip -> tools_r25.3.1
RUN cd /opt && wget -q https://dl.google.com/android/repository/sdk-tools-linux-3773319.zip -O android-sdk-tools.zip
RUN cd /opt && unzip -q android-sdk-tools.zip
RUN mkdir -p ${ANDROID_HOME}
RUN cd /opt && mv tools/ ${ANDROID_HOME}/tools/
RUN cd /opt && rm -f android-sdk-tools.zip

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${ANDROID_NDK_HOME}

# ------------------------------------------------------
# --- Install Android SDKs and other build packages

# Accept all licenses before installing components.
RUN yes | sdkmanager --licenses

# Platform tools
RUN sdkmanager "platform-tools"
RUN sdkmanager "tools"

# SDKs
RUN sdkmanager "platforms;android-25"
RUN sdkmanager "platforms;android-24"
RUN sdkmanager "platforms;android-23"
RUN sdkmanager "platforms;android-22"
RUN sdkmanager "platforms;android-21"
RUN sdkmanager "platforms;android-20"
RUN sdkmanager "platforms;android-19"
RUN sdkmanager "platforms;android-18"
#RUN sdkmanager "platforms;android-17"
#RUN sdkmanager "platforms;android-16"
RUN sdkmanager "platforms;android-15"

# build tools
RUN sdkmanager "build-tools;25.0.2"
RUN sdkmanager "build-tools;25.0.1"
RUN sdkmanager "build-tools;25.0.0"
RUN sdkmanager "build-tools;24.0.3"
RUN sdkmanager "build-tools;24.0.2"
RUN sdkmanager "build-tools;24.0.1"
RUN sdkmanager "build-tools;24.0.0"
RUN sdkmanager "build-tools;23.0.3"
RUN sdkmanager "build-tools;23.0.2"
RUN sdkmanager "build-tools;23.0.1"
RUN sdkmanager "build-tools;22.0.1"
RUN sdkmanager "build-tools;21.1.2"
RUN sdkmanager "build-tools;20.0.0"
RUN sdkmanager "build-tools;19.1.0"

# Extras
RUN sdkmanager "extras;android;m2repository"
RUN sdkmanager "extras;google;m2repository"
RUN sdkmanager "extras;google;google_play_services"

# Constraint Layout
RUN sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2"
RUN sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.1"
RUN sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.0"

RUN sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"
RUN sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1"
RUN sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.0"

# google apis
RUN sdkmanager "add-ons;addon-google_apis-google-24"
RUN sdkmanager "add-ons;addon-google_apis-google-23"
RUN sdkmanager "add-ons;addon-google_apis-google-22"
RUN sdkmanager "add-ons;addon-google_apis-google-21"
RUN sdkmanager "add-ons;addon-google_apis-google-19"

# ------------------------------------------------------
# --- Install Maven
RUN apt-get purge maven maven2
RUN apt-get update -qq && apt-get -y --no-install-recommends install maven gradle
RUN mvn --version
# Install Git-lfs
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install git-lfs
RUN git lfs install

## Gradle Wrapper pre-download.
#RUN mkdir -p /tmp/gradle-wrapper && cd /tmp/gradle-wrapper
#RUN gradle wrapper --gradle-version 2.10 -PdistributionType=ALL && ./gradlew
#RUN gradle wrapper --gradle-version 2.14.1 -PdistributionType=ALL && ./gradlew
#RUN gradle wrapper --gradle-version 3.3 -PdistributionType=ALL && ./gradlew
# ------------------------------------------------------

# Cleanup
RUN apt-get clean -y && apt-get autoremove -y
RUN rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Go to workspace
RUN mkdir -p /var/workspace
WORKDIR /var/workspace