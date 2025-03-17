FROM varnish:6.0

COPY default.vcl /etc/varnish/default.vcl

EXPOSE 6081
EXPOSE 6082

CMD ["varnishd", "-F", "-f", "/etc/varnish/default.vcl", "-s", "malloc,256m", "-T", "0.0.0.0:6082", "-a", ":6081"]
