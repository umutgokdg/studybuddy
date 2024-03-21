FROM ubuntu:jammy

WORKDIR /usr/src/app

RUN apt-get update \
    && apt-get install -y curl git build-essential libssl-dev

ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 18.18.2
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

EXPOSE 3500

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
