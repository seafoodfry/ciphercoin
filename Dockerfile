#FROM rust:1.89-bullseye
FROM ghcr.io/foundry-rs/foundry:v1.3.5

ARG USER_ID=1000
ARG GROUP_ID=1000

# Default user in foundry image is
# uid=1000(foundry) gid=1000(foundry) groups=1000(foundry)
USER root
RUN adduser --disabled-password --uid ${USER_ID} devuser && \
    mkdir -p /home/devuser && \
    chown devuser:devuser /home/devuser

USER devuser
# https://getfoundry.sh/introduction/installation/
#RUN curl -L https://foundry.paradigm.xyz | bash
#ENV PATH="/home/devuser/.foundry/bin:$PATH"

WORKDIR /home/devuser/workspace