# based on https://github.com/trajano/nginx-letsencrypt
FROM nginx:1.29.8-trixie
EXPOSE 443
VOLUME /etc/letsencrypt

# Update and install packages
RUN apt-get update && \
    apt-get install -y python3-urllib3 openssl python3 python3-venv libaugeas0 curl bash && \
    rm -rf /var/cache/apk/*

# Setup Python environment
RUN python3 -m venv /opt/certbot/ && \
    /opt/certbot/bin/pip install --upgrade pip

# Install cerbot
RUN /opt/certbot/bin/pip install certbot && \
    ln -s /opt/certbot/bin/certbot /usr/bin/certbot

# Copy configs and init scripts
COPY nginx-files/* /etc/nginx/
COPY init.sh /init
COPY certbot-renew.sh /etc/cron.weekly/certbot-renew

# Set correct permissions
RUN chmod +x /etc/cron.weekly/certbot-renew
RUN chmod 700 /init
RUN mkdir /etc/nginx/site.d /etc/nginx/deployment.d && \
     rm /etc/nginx/conf.d/default.conf

CMD [ "/init" ]

HEALTHCHECK --start-period=120s CMD curl --fail http://localhost/.well-known/ping || exit 1
