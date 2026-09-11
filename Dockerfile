FROM jenkins/inbound-agent:latest-jdk21

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       python3 \
       python3-pip \
       python3-venv \
    && rm -rf /var/lib/apt/lists/*

RUN python3 --version \
    && pip3 --version

USER jenkins
