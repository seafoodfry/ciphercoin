FROM rust:1.89-bullseye


ARG USER_ID=1000
ARG GROUP_ID=1000

RUN adduser --disabled-password --uid ${USER_ID} devuser && \
    mkdir -p /home/devuser && \
    chown devuser:devuser /home/devuser

USER devuser
# https://getfoundry.sh/introduction/installation/
RUN curl -L https://foundry.paradigm.xyz | bash
ENV PATH="/home/devuser/.foundry/bin:$PATH"

WORKDIR /home/devuser/workspace