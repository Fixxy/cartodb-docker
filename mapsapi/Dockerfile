FROM buildpack-deps:16.04

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update \
  && apt-get -y --no-install-recommends install \
    build-essential \
    git \
    libcairo2-dev \
    libgif-dev \
    libjpeg-dev \
    libpango1.0-dev \
    nodejs \
    yarn=0.27.5-1 \
  && rm -rf /var/lib/apt/lists/*

# Installing zlib 1.2.9
RUN wget https://github.com/madler/zlib/archive/v1.2.9.tar.gz \
  && tar -zxvf v1.2.9.tar.gz \
  && cd zlib-1.2.9 \
  && ./configure --prefix=/bin/zlib/ \
  && make && make install

ENV LD_LIBRARY_PATH="/bin/zlib/lib"

# Install the application.
RUN git clone https://github.com/Global-Mapping-Hub/Windshaft-cartodb.git \
  && cd /Windshaft-cartodb \
  && chmod +x scripts/*.sh \
  && yarn \
  && mkdir /Windshaft-cartodb/logs

# Copy resources.
COPY config/*.js /Windshaft-cartodb/config/environments/
COPY docker-entrypoint.sh /usr/local/bin/

WORKDIR /Windshaft-cartodb

EXPOSE 80

# We configure the application using just the base config here. Additional configuration files can
# be merged with the base by supplying their filenames as the CMD.
ENTRYPOINT [ "docker-entrypoint.sh", "base.config.js" ]

# We use the development example config by default. Alternatives:
# - production.js.example
# - staging.js.example
# - test.js.example
# OR extend this image by COPYing a custom config file into /Windshaft-cartodb/config/environments/
# and passing its name as the CMD.
CMD [ "development.js.example" ]
