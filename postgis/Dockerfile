FROM ubuntu:16.04

# Basics
RUN apt-get update && apt-get -y --no-install-recommends install \
    build-essential \
    software-properties-common python-software-properties \
    git \
    curl \
    wget \
    ca-certificates

# Add PPAs
RUN add-apt-repository ppa:cartodb/gis \
   && add-apt-repository ppa:cartodb/postgresql-10

# PostgreSQL
RUN apt-get update && apt-get -y install --no-install-recommends \
    libpq-dev \
    libpq5 \
    postgresql-10 \
    postgresql-plpython-10 \
    postgresql-client-10 \
    postgresql-client-common \
    postgresql-10-plproxy \
    postgresql-server-dev-10 \
    # GIS:
    # - Proj
    libproj-dev \
    proj-bin \
    proj-data \
    # - GEOS
    libgeos-c1v5 \
    libgeos-dev \
    # - GDAL
    gdal-bin \
    libgdal-dev

# PostGIS
RUN apt-get update && apt-get -y install \
    libxml2-dev \
    postgis \
    postgresql-10-postgis-2.4 \
    postgresql-10-postgis-2.4-scripts

# pgbin paths
ENV PATH="$PATH:/usr/lib/postgresql/10/bin/"

# Installing build and ruby dependencies
RUN apt-get update && apt-get -y install --no-install-recommends \
  libsdl2-dev libsdl2-ttf-dev libpango1.0-dev \
  libgl1-mesa-dev libopenal-dev libsndfile-dev libmpg123-dev \
  libgmp-dev libgtk-3-dev

# Installing Ruby
RUN wget -O ruby-install.tar.gz https://github.com/postmodern/ruby-install/archive/v0.9.3.tar.gz \
  && tar -xzvf ruby-install.tar.gz \
  && cd ruby-install-0.9.3/ \
  && make install \
  && ruby-install ruby 2.7.5 \
  # Clean up.
  && cd .. \
  && rm ruby-install.tar.gz \
  && rm -rf ruby-install-0.9.3

ENV PATH=/opt/rubies/ruby-2.7.5/bin:$PATH
    
# Installing gosu
RUN set -eux && \
  apt-get update && \
  apt-get install -y gosu && \
  rm -rf /var/lib/apt/lists/* && \
  # verify that the binary works
  gosu nobody true

# Relink pg_config
RUN rm -rf /usr/bin/pg_config
RUN ln -s /usr/lib/postgresql/10/bin/pg_config /usr/bin/pg_config

# https://github.com/CartoDB/cartodb-postgresql version
ENV CARTODB_POSTGRESQL_VERSION=0.36.0
# https://github.com/CartoDB/crankshaft version
ENV CRANKSHAFT_VERSION=0.8.1
# https://github.com/CartoDB/data-services
ENV DATASERVICES_VERSION=0.0.2
# https://github.com/CartoDB/dataservices-api
ENV DATASERVICESAPI_VERSION=python-0.20.2
# https://github.com/CartoDB/observatory-extension
ENV OBSERVATORY_VERSION=1.9.0

# Installing Python
RUN apt-get update && apt-get -y --no-install-recommends install \
    python2.7 \
    python2.7-dev

# Install pip2
RUN wget -O /tmp/get-pip.py https://bootstrap.pypa.io/pip/2.7/get-pip.py \
  && python /tmp/get-pip.py \
  # Clean up.
  && rm /tmp/get-pip.py \
  && rm -rf /var/lib/apt/lists/*

# Install CartoDB main postgresql extensions
RUN git clone \
    --branch ${CARTODB_POSTGRESQL_VERSION} \
    --depth 1 https://github.com/CartoDB/cartodb-postgresql.git \
  && cd cartodb-postgresql \
  && make all install \
  && cd /

# Install
RUN git clone \
    --branch ${CRANKSHAFT_VERSION} \
    --depth 1 https://github.com/CartoDB/crankshaft.git \
  && cd /crankshaft \
  && make install

# Numpy gets upgraded after scikit-learn is installed
# make sure scikit-learn is compatible with currently installed numpy, by reinstalling
RUN cd /crankshaft && pip install --force-reinstall --no-cache-dir scikit-learn==0.14.1

# Geocoder
RUN cd / && git clone \
    --branch ${DATASERVICES_VERSION} \
    --depth 1 https://github.com/CartoDB/data-services.git \
  && cd /data-services/geocoder/extension \
  && PGUSER=$POSTGRES_USER make all install

# Dataservices
RUN cd / && git clone \
    --branch ${DATASERVICESAPI_VERSION} \
    --depth 1 https://github.com/CartoDB/dataservices-api.git \
  && cd /dataservices-api/server/extension \
  && PGUSER=$POSTGRES_USER make install \
  && cd ../lib/python/cartodb_services \
  && pip install -r requirements.txt && pip install . \
  && cd ../../../../client \
  && PGUSER=$POSTGRES_USER make install

# Observatory extension
RUN cd / && git clone \
    --branch ${OBSERVATORY_VERSION} \
    --depth 1 https://github.com/CartoDB/observatory-extension.git \
  && cd observatory-extension \
  && PGUSER=$POSTGRES_USER make deploy

# postgres initdb scripts
RUN mkdir -p /docker-entrypoint-initdb.d

COPY docker-entrypoint.sh /usr/local/bin/
COPY initdb-postgis.sh /docker-entrypoint-initdb.d/01-postgis.sh
RUN chmod +rx /docker-entrypoint-initdb.d/01-postgis.sh
RUN chmod 777 /usr/local/bin/docker-entrypoint.sh

# Expose Postgres port
EXPOSE 5432

# Let Postgres listen on all addresses (it's just localhost by default).
ENTRYPOINT [ "docker-entrypoint.sh", "postgres", "-c", "listen_addresses=*" ]

# Empty CMD directive to override CMD in the base image.
# Additional configuration options can be passed via a custom command.
CMD []
