# cartodb-docker

Based on [ihmeuw/cartodb-docker](https://github.com/ihmeuw/cartodb-docker)

This repository provides a Docker Compose setup for running a complete [CartoDB](https://github.com/CartoDB/cartodb) environment using Docker. It includes subdirectories for each Carto service, along with a reverse proxy configuration to route all requests through a single endpoint with SSL support.

Builds successfully on Ubuntu 24.04.1 LTS

## Carto Services

1. **`editor`**: Runs the [Carto web application](https://github.com/CartoDB/cartodb).
2. **`mapsapi`**: Hosts the [Windshaft map tile API server](https://github.com/CartoDB/Windshaft-cartodb), which generates Carto map tiles.
3. **`sqlapi`**: Runs the [SQL API server](https://github.com/CartoDB/CartoDB-SQL-API), which allows you to interact with your data inside CARTO, as if you were running SQL statements against a normal database.
4. **`postgis`**: A PostgreSQL + PostGIS database container, configured to persist data on disk. Sets up [Carto-specific extension](https://github.com/CartoDB/cartodb-postgresql) to support spatial queries.
5. **`redis`**: A standard Redis instance for caching and data storage, configured to persist data on disk.

## Reverse Proxy (Router)

- **`router`**: Contains a Dockerfile for an Nginx-based reverse proxy that allows access to all Carto services via a single base URL. SSL support is included using [Certbot](https://certbot.eff.org/) to generate and renew Let’s Encrypt certificates.

## Getting Started

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### Setup

1. Clone this repository:

   ```bash
   git clone https://github.com/Fixxy/cartodb-docker.git
   cd cartodb-docker

2. Create and set up the .env file

3. Run the containers
   ```bash
    sudo docker compose up --detach