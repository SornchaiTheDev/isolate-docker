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

FROM debian:bookworm-slim

RUN apt update && apt install -y libcap2 && rm -rf /var/lib/apt/lists/*

COPY --from=build /isolate/isolate /usr/local/bin/isolate

COPY --from=build /isolate/isolate-check-environment /usr/local/bin/isolate-check-environment

RUN chmod +x /usr/local/bin/isolate

# Set up Isolate's configuration file (ensure cgroup v2 location is correct)
# Add any specific Isolate configuration here, if needed

# Optional: Disable swap for reproducibility
RUN swapoff -a

# Create the UID and GID range for sandboxes
RUN groupadd -g 60000 isolate_group \
	&& useradd -u 60000 -g isolate_group isolate_user

# Add an entrypoint to run Isolate commands inside the container
ENTRYPOINT ["/usr/local/bin/isolate"]

# Set a default command, e.g., to run an isolated program
CMD ["/bin/sh"]
