FROM ruby:2.5.1

ARG PG_VERSION
ARG NODE_VERSION
ARG YARN_VERSION
ARG TINI_VERSION=v0.18.0

RUN curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' $PG_VERSION > /etc/apt/sources.list.d/pgdg.list \
  && curl -o /tmp/nodejs.deb https://deb.nodesource.com/node_8.x/pool/main/n/nodejs/nodejs_$NODE_VERSION-1nodesource1_amd64.deb \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list \
  && curl https://dl-ssl.google.com/linux/linux_signing_key.pub  | apt-key add - \
  && echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb stable main' >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
  build-essential \
  less \
  vim \
  postgresql-client-$PG_VERSION \
  /tmp/nodejs.deb \
  yarn=$YARN_VERSION-1 \
  google-chrome-unstable \
  ghostscript libgs-dev \
  graphviz \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

ENV LANG=C.UTF-8 \
  GEM_HOME=/bundle \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3
ENV BUNDLE_PATH $GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH \
  BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH $BUNDLE_BIN:$PATH

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN mkdir -p /app

WORKDIR /app
ENTRYPOINT ["/tini", "--"]
