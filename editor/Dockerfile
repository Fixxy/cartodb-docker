FROM ubuntu:16.04

RUN apt-get update \
  # Install locales package, and update locale
  && apt-get install -y --no-install-recommends locales \
  && locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
  # Install python-software-properties package to make it easier to use PPAs.
  && apt-get -y --no-install-recommends install \
    software-properties-common python-software-properties \
  # Add PPAs.
  && add-apt-repository ppa:cartodb/gis \
  && add-apt-repository ppa:cartodb/postgresql-10 \
  # Install apt packages.
  && apt-get update && apt-get -y --no-install-recommends install \
    # build essentials
    autoconf \
    binutils-doc \
    bison \
    build-essential \
    flex \
    wget \
    gcc \
    g++ \
    # some utils
    less vim.tiny \
    # Git
    git \
    # networking tools, because 'ip' is required by uuidtools gem to get mac addr
    iproute2 \
    # PostgreSQL
    libpq5 \
    libpq-dev \
    postgresql-10 \
    postgresql-plpython-10 \
    postgresql-client-10 \
    postgresql-client-common \
    # GIS:
    # - Proj
    proj-bin \
    proj-data \
    libproj-dev \
    # - JSON
    libjson0 \
    libjson0-dev \
    python-simplejson \
    # - GEOS
    libgeos-c1v5 \
    libgeos-dev \
    # - GDAL
    gdal-bin \
    libgdal-dev \
    libgdal1-dev \
    # Postgis
    libxml2-dev \
    postgis

# Ruby
#RUN apt-get install -y ruby2.5 \
#    ruby2.5-dev \
#    ruby-bundler
RUN wget -O ruby-install.tar.gz https://github.com/postmodern/ruby-install/archive/v0.9.3.tar.gz \
  && tar -xzvf ruby-install.tar.gz \
  && cd ruby-install-0.9.3/ \
  && make install \
  && ruby-install ruby 3.0.7 \
  # Clean up.
  && cd .. \
  && rm ruby-install.tar.gz \
  && rm -rf ruby-install-0.9.3

# Other dependencies (python, wget, etc)
RUN apt-get install -y imagemagick \
    python-all-dev \
    libicu-dev \
    libreadline6-dev \
    openssl \
    unp \
    zip \
    # for user migration rake tasks
    redis-tools \
    # Other dependencies
    unzip \
    wget \
    curl

# Install Pip.
RUN wget -O /tmp/get-pip.py https://bootstrap.pypa.io/pip/2.7/get-pip.py \
  && python /tmp/get-pip.py \
  # Clean up.
  && rm /tmp/get-pip.py \
  && rm -rf /var/lib/apt/lists/*

# Install Ruby utilities.
ENV CC=/usr/bin/gcc-5
ENV CXX=/usr/bin/g++-5
ENV PATH=/opt/rubies/ruby-3.0.7/bin:$PATH
RUN gem install bundler:1.17.3
RUN gem install compass

# Install NodeJS dependencies
RUN apt-get update && apt-get install -y \
    libgif-dev \
    libjpeg-dev \
    libpixman-1-0

# Install NodeJS
RUN curl -fsSL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get update && apt-get install -y nodejs npm
RUN nodejs -v && npm -v && asdasd
RUN npm install npm@6.14.18 -g

# GitHub changes for editor to install properly
RUN git config --global url."https://".insteadOf git://

# Download the Editor program, using the specified release tag.
RUN git clone --recursive --depth 1 https://github.com/Global-Mapping-Hub/cartodb.git

WORKDIR /cartodb

# Environment type.
ARG RAILS_ENV=development
ENV RAILS_ENV=$RAILS_ENV

# Install Ruby dependencies.
RUN bundle install \
  # Install Python dependencies.
  && CPLUS_INCLUDE_PATH=/usr/include/gdal \
    C_INCLUDE_PATH=/usr/include/gdal \
    PATH=$PATH:/usr/include/gdal \
    pip install -r python_requirements.txt

# Install Node dependencies
RUN npm install

# Add dependencies of configuration merge script.
RUN npm install js-yaml yargs
RUN npm install grunt --save-dev

COPY config/* /cartodb/config/

# Compile static assets
RUN PATH=$PATH:/cartodb/node_modules/grunt-cli/bin \
    bundle exec grunt --environment=${RAILS_ENV} \
  # Clean up.
  && rm -rf \
    /root/.cache \
    /root/.bundle \
    /root/.gem \
    /root/.npm \
  && mkdir -p /cartodb/docker-entrypoint-util

EXPOSE 3000

# Copy resources.
COPY util/* /cartodb/docker-entrypoint-util/
COPY docker-entrypoint.sh /cartodb/

# We configure the application using just the base config files here. Additional configuration files
# can be merged with the base by supplying their filenames as --app_config or --database option
# arguments in the CMD.
ENTRYPOINT [ \
  "./docker-entrypoint.sh", \
  "--app_config", "base.app_config.yml", \
  "--database", "base.database.yml" \
]

# We merge the sample config files with the base configs by default.
# Custom configuration may be used by extending this image as follows:
# 1) COPY one or more config files into /cartodb/config/.
# 2) Pass the filename(s) as --app_config or --database option arguments in the CMD.
CMD [ \
  "--app_config", "app_config.yml.sample", \
  "--database", "database.yml.sample" \
]
