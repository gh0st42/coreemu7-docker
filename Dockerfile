FROM ubuntu:20.04
LABEL Description="Docker image for core network emulator"


ENV DEBIAN_FRONTEND noninteractive

# development tools
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    iputils-ping \
    net-tools \
    wget \
    curl \
    vim \
    nano \
    mtr \
    tmux \
    iperf \
    git \
    binutils \
    ssh \
    && apt-get clean

# CORE dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    quagga \
    lxterminal \
    xauth \
    psmisc \
    sudo \
    imagemagick \
    openvswitch-switch \
    && apt-get clean

# CORE
RUN wget --quiet https://github.com/coreemu/core/archive/release-7.5.1.tar.gz \
    && tar xvf release* \
    && rm release*.tar.gz
#RUN git clone https://github.com/coreemu/core \
#    && cd core \

RUN cd core-release-7.5.1 \
    && ./install.sh 
#    && export PATH=$PATH:/root/.local/bin \

#WORKDIR /root
#RUN wget https://raw.githubusercontent.com/coreemu/core/master/daemon/requirements.txt && \
#   python3 -m pip install -r requirements.txt && \
#   rm requirements.txt

# various last minute deps

# evaluation dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    htop \
    sysstat \
    bwm-ng \
    ripgrep \
    && apt-get clean

WORKDIR /root
RUN git clone https://github.com/gh0st42/core-helpers &&\
    cd core-helpers && ./install-symlinks.sh

WORKDIR /root
RUN git clone https://github.com/gh0st42/core-automator &&\
    pip install appjar &&\
    cp core-automator/*.py /usr/local/bin

# enable sshd
RUN mkdir /var/run/sshd &&  sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#X11UseLocalhost yes/X11UseLocalhost no/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV PASSWORD "netsim"
RUN echo "root:$PASSWORD" | chpasswd

ENV SSHKEY ""

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

# ADD extra /extra
VOLUME /shared

COPY entryPoint.sh /root/entryPoint.sh
ENTRYPOINT "/root/entryPoint.sh"

