FROM buildpack-deps:16.04

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
  && apt-get update \
  && apt-get -y --no-install-recommends install \
    nodejs \
    git \
  && rm -rf /var/lib/apt/lists/*

# CartoDB/CartoDB-SQL-API version
RUN git clone --depth 1 https://github.com/Global-Mapping-Hub/CartoDB-SQL-API.git \
  && cd /CartoDB-SQL-API \
  && npm install

# Copy resources.
COPY config/*.js /CartoDB-SQL-API/config/environments/
COPY docker-entrypoint.sh /usr/local/bin/

WORKDIR /CartoDB-SQL-API

EXPOSE 80

# We configure the application using just the base config here. Additional configuration files can
# be merged with the base by supplying their filenames as the CMD.
ENTRYPOINT [ "docker-entrypoint.sh", "base.config.js" ]

# We use the development example config by default. Alternatives:
# - production.js.example
# - staging.js.example
# - test.js.example
# OR extend this image by COPYing a custom config file into /CartoDB-SQL-API/config/environments/
# and passing its name as the CMD.
CMD [ "development.js.example" ]
