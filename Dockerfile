#FROM rust:1.89-bullseye
FROM ghcr.io/foundry-rs/foundry:v1.4.4

ARG USER_ID=1000

# Default user in foundry image is
# uid=1000(foundry) gid=1000(foundry) groups=1000(foundry)
USER root
RUN if [ "${USER_ID}" != "1000" ]; then \
        deluser foundry && \
        adduser --disabled-password --uid ${USER_ID} devuser && \
        mkdir -p /home/devuser && \
        chown devuser:devuser /home/devuser; \
    else \
        usermod -l devuser foundry && \
        groupmod -n devuser foundry && \
        usermod -d /home/devuser -m devuser; \
    fi

RUN apt-get update -y && \
    apt-get install -y \
    strace

USER devuser
# https://getfoundry.sh/introduction/installation/
#RUN curl -L https://foundry.paradigm.xyz | bash
#ENV PATH="/home/devuser/.foundry/bin:$PATH"

WORKDIR /home/devuser/workspace