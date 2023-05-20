FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        file \
        git \
        less \
        locales \
        locales-all \
        sudo \
        vim \
    && rm -rf /var/lib/apt/lists/*

# Dependencies documented on Github
RUN apt-get update && apt-get install -y --no-install-recommends \
        make automake libtool pkg-config libaio-dev \
        libmysqlclient-dev libssl-dev \
        libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Set locales
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN echo 'root:root' | chpasswd

ARG USER_NAME=user
RUN adduser --disabled-password --gecos "" ${USER_NAME}
RUN adduser ${USER_NAME} sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER ${USER_NAME}

WORKDIR /home/${USER_NAME}
RUN touch ~/.sudo_as_admin_successful
RUN mkdir workspace
RUN mkdir imagebuild

WORKDIR /home/${USER_NAME}/imagebuild
ARG SYSBENCH_VERSION=1.0.20
RUN git clone --branch ${SYSBENCH_VERSION} --depth 1 https://github.com/akopytov/sysbench.git 2> /dev/null
WORKDIR /home/${USER_NAME}/imagebuild/sysbench

RUN ./autogen.sh
RUN ./configure --without-mysql --without-pgsql
RUN make -j "$(nproc)"
RUN sudo make install

WORKDIR /home/${USER_NAME}/workspace
