# nginx-docker

A slim nginx image with limited configurability via environment variables.

Use this when you need to add a buffering reverse proxy or basic authentication in front of another service in your stack.

For exmple, [gunicorn](http://docs.gunicorn.org/en/stable/deploy.html) recommends nginx and requires a buffering reverse proxy for the default `sync` worker class.

Features:

- Sensible default configuration as buffering reverse proxy
- Can be configured via environment variables
- Sets `Host`, `X-Forwarded-For` and `X-Forwarded-Proto` headers
- Supports websocket connections
- Allows large file uploads
- Buffering can be disabled to support streaming request/responses, long polling, etc.
- Optional basic authentication

It does not do dynamic configuration, SSL termination, or virtual host routing. Use [dockercloud-haproxy](https://github.com/docker/dockercloud-haproxy) or [traefik](https://github.com/containous/traefik) in front for that.


# Usage

```yaml
version: '3.6'

services:
  gunicorn:
    ...

  nginx:
    environment:
      # dockercloud-haproxy config
      SERVICE_PORTS: 8000
      VIRTUAL_HOST: https://${SITE_DOMAIN}
      # nginx config
      NGINX_BASIC_AUTH:            # {username}:{password}
      NGINX_LISTEN:                # 8000
      NGINX_CLIENT_MAX_BODY_SIZE:  # 500m
      NGINX_PROXY_BUFFERING:       # on
      NGINX_PROXY_PASS:            # http://gunicorn:8080
      NGINX_WORKER_PROCESSES:      # auto
    healthcheck:
      test: dockerize -wait tcp://localhost:8000 || exit 1
    image: interaction/nginx
```

**WARNING:** If your `nginx` service is joining an external network (e.g. for dockercloud-haproxy or traefik), ensure that your proxied service name (e.g. `gunicorn`) does not conflict with other services that are also connected to the external network.


# Known issues

When the proxied container is restarted it will get a new IP address and nginx will no longer be able to connect as it caches DNS results when a hostname is used in `NGINX_PROXY_PASS`.
