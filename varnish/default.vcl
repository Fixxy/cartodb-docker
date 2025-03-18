vcl 4.1;

acl purge {
    "localhost";
    "127.0.0.1";
    "cartodb-varnish";
    "172.0.0.0/8";
}

backend sqlapi {
    .host = "cartodb-sqlapi";
    .port = "8080";
    .connect_timeout = 5s;
    .first_byte_timeout = 90s;
    .between_bytes_timeout = 2s;
}

backend mapsapi {
    .host = "cartodb-mapsapi";
    .port = "8181";
    .connect_timeout = 5s;
    .first_byte_timeout = 90s;
    .between_bytes_timeout = 2s;
}

sub vcl_recv {
    # Allowing PURGE from localhost
    if (req.method == "PURGE") {
        if (!client.ip ~ purge) {
            return (synth(405, "Not allowed."));
        }
        return (hash);
    }

    # Routing request to backend based on X-Carto-Service header from nginx
    if (req.http.X-Carto-Service == "sqlapi") {
        set req.backend_hint = sqlapi;
        unset req.http.X-Carto-Service;
    }
    if (req.http.X-Carto-Service == "mapsapi") {
        set req.backend_hint = mapsapi;
        unset req.http.X-Carto-Service;
    }
}

sub vcl_hit {
    if (req.method == "PURGE") {
        ban("req.url ~ " + req.url);
        return (deliver);
    }
}

sub vcl_miss {
    if (req.method == "PURGE") {
        ban("req.url ~ " + req.url);
        return (synth(200, "Purged."));
    }
}
