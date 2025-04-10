FROM ubuntu:22.04 AS build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt install git \
	build-essential \
	pkg-config \
	libsystemd-dev \
	libcap-dev \
	-y

RUN git clone https://github.com/ioi/isolate.git

WORKDIR /isolate

RUN make isolate
RUN make isolate-cg-keeper

FROM debian:bookworm-slim

RUN apt update 
RUN apt install --no-install-recommends -y libcap2 \
build-essential  \
libcap-dev \
sysfsutils \
libsystemd-dev \
pkg-config \
libssl-dev

RUN rm -rf /var/lib/apt/lists/*

COPY --from=build /isolate/isolate /usr/local/bin/isolate
COPY --from=build /isolate/isolate-check-environment /usr/local/bin/isolate-check-environment
COPY --from=build /isolate/isolate-cg-keeper /usr/local/bin/isolate-cg-keeper
COPY --from=build /isolate/systemd/isolate.service /etc/systemd/system/isolate.service
COPY --from=build /isolate/systemd/isolate.slice /etc/systemd/system/isolate.slice


RUN chmod +x /usr/local/bin/isolate

# Set up Isolate's configuration file (ensure cgroup v2 location is correct)
# Add any specific Isolate configuration here, if needed

# Create the UID and GID range for sandboxes
RUN groupadd -g 60000 isolate_group \
	&& useradd -u 60000 -g isolate_group isolate_user


# Config TZ
ENV TZ=Asia/Bangkok
RUN apt-get update && \
    apt-get install -y tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set up compiler and interpreter environments

# Python Lang
RUN apt update 
RUN apt install -y python3 python3-pip

# C Lang
RUN apt install -y gcc

# C++ Lang
RUN apt install -y g++

# Java Lang
RUN apt install -y openjdk-17-jdk

# Go Lang
RUN apt install -y golang-go

# NodeJS Lang
RUN apt install -y nodejs

COPY ./container-extra-config.sh /usr/local/bin/container-extra-config.sh

RUN chmod +x /usr/local/bin/container-extra-config.sh

COPY ./container-extra-config.service /etc/systemd/system/container-extra-config.service

RUN systemctl enable container-extra-config.service
RUN systemctl enable isolate.service

STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
