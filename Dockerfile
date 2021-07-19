FROM ubuntu:20.04
LABEL Description="Docker image for core network emulator"


ENV DEBIAN_FRONTEND noninteractive

# development tools
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    iputils-ping \
    net-tools \
    iproute2 \
    vlan \
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
    tcpdump \
    && rm -rf /var/lib/apt/lists/*

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
    docker.io \
    openvswitch-switch \
    && rm -rf /var/lib/apt/lists/*

# CORE
RUN wget --quiet https://github.com/coreemu/core/archive/release-7.5.1.tar.gz \
    && tar xvf release* \
    && rm release*.tar.gz
#RUN git clone https://github.com/coreemu/core \
#    && cd core \

RUN apt-get update && \
    cd core-release-7.5.1 \
    && ./install.sh \
    && export PATH=$PATH:/root/.local/bin \
    && inv install-emane \
    && rm -rf /var/lib/apt/lists/*

#RUN apt-get update && \
#apt-get -y install libtool libxml2-dev protobuf-compiler libpcre3-dev uuid-dev libpcap-dev && \
#rm -rf /var/lib/apt/lists/*

#RUN wget --quite https://github.com/adjacentlink/emane/archive/refs/tags/v1.2.7.tar.gz && \
#tar xvf v1.2.7.tar.gz && \
#cd emane-1.2.7 && \
#./autogen.sh && \
#./configure && \
#make && \
#make deb

#RUN wget --quiet https://adjacentlink.com/downloads/emane/emane-1.2.7-release-1.ubuntu-20_04.amd64.tar.gz && \
#tar xvf emane-1.2.7-release-1.ubuntu-20_04.amd64.tar.gz && \
#cd emane-1.2.7-release-1/debs/ubuntu-20_04/amd64 && \
#apt-get update && \
#dpkg -i *.deb ; \
#apt-get install -f -y && \
#rm -rf /var/lib/apt/lists/*

#make install && \

#WORKDIR /root
#RUN wget https://raw.githubusercontent.com/coreemu/core/master/daemon/requirements.txt && \
#   python3 -m pip install -r requirements.txt && \
#   rm requirements.txt

# various last minute deps

WORKDIR /root
RUN git clone https://github.com/gh0st42/core-helpers &&\
    cp core-helpers/bin/* /usr/local/bin &&\
    rm -rf core-helpers

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

RUN sed -i 's/grpcaddress = localhost/grpcaddress = 0.0.0.0/g' /etc/core/core.conf
EXPOSE 22

# ADD extra /extra
VOLUME /shared

COPY entryPoint.sh /root/entryPoint.sh
ENTRYPOINT "/root/entryPoint.sh"

