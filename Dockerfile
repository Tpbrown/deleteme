# Build using: GO_VERSION=16.x.x-xxxx docker build -f Dockerfile.alpine-gocd-server --tag=alpine-gocd-server .

FROM delitescere/jdk:latest
#ENV GO_VERSION=16.5.0-3305
ENV GO_VERSION=16.6.0-3590
MAINTAINER GoCD <go-cd-dev@googlegroups.com>
RUN env
# GoCD scripts used here work with ash -- bash not needed.  Only git support is bundled.
RUN apk --no-cache add git

# Exposing volumes in a simple manner, and setup links behind-the-scenes to match GoCD's directory structure
# This requires some bootstrapping in alpine-start.sh
RUN mkdir -p /config/default /config/db /config/addons /config/plugins /artifacts /logs /var/lib/go-server/plugins /tmp && \
  ln -sf /artifacts /var/lib/go-server/artifacts && \
  ln -sf /config /var/lib/go-server/config && \
  ln -sf /config/addons /var/lib/go-server/addons && \
  ln -sf /config/db /var/lib/go-server/db && \
  ln -sf /config/etc /etc/go && \
  ln -sf /config/plugins /var/lib/go-server/plugins/external && \
  ln -sf /logs /var/log/go-server

VOLUME ["/config", "/artifacts", "/logs"]

EXPOSE 8153 8154

# Dockerized startup script.  Should work on more than Alpine, but YMMV.
COPY gocd-server/alpine-start.sh /start

CMD ["/start"]

# Download Go and install into a consistent directory. Disable daemonize.
WORKDIR /
RUN wget -qO- https://download.go.cd/binaries/$GO_VERSION/generic/go-server-$GO_VERSION.zip \
  # Using 'jar' because 'unzip' doesn't support stdin, and bsdtar is not available on Alpine
  # Can't extract only specific files because we're working on stdin.
  |jar xf /dev/stdin && \
  # Note this rename won't work if /go-server already exists... (it'll move the dir inside /go-server)
  mv ./go-server-* ./go-server && \
  sed -e 's/DAEMON=Y/DAEMON=N/' /go-server/default.cruise-server > /config/default/go-server && \
  # Trash any temp files
  rm -rf go-server-* /var/tmp/* /go-server/init.* /go-server/server.cmd /go-server/*.bat /go-server/*.sh /go-server/default.* /go-server/defaultFiles
