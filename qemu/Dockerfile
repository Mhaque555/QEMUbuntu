FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 qemu-utils \
    novnc websockify \
    wget ca-certificates coreutils \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /storage /opt/scripts
WORKDIR /storage

COPY entrypoint.sh /opt/scripts/entrypoint.sh
RUN chmod +x /opt/scripts/entrypoint.sh

EXPOSE 5900 6080
ENTRYPOINT ["/opt/scripts/entrypoint.sh"]
