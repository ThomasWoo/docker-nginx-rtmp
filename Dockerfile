ARG NGINX_VERSION=1.18.0
ARG NGINX_RTMP_VERSION=1.2.1

##############################
FROM alpine:3.12 as build-container
ARG NGINX_VERSION
ARG NGINX_RTMP_VERSION

RUN set -ex && \
  apk add --update \
    build-base \
    ca-certificates \
    curl \
    gcc \
    libc-dev \
    libgcc \
    linux-headers \
    make \
    musl-dev \
    openssl \
    openssl-dev \
    pcre \
    pcre-dev \
    pkgconf \
    pkgconfig \
    zlib-dev && \
  cd /tmp && \
  wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
  tar zxf nginx-${NGINX_VERSION}.tar.gz && \
  rm nginx-${NGINX_VERSION}.tar.gz && \
  wget https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_VERSION}.tar.gz && \
  tar zxf v${NGINX_RTMP_VERSION}.tar.gz && \
  rm v${NGINX_RTMP_VERSION}.tar.gz && \
  cd /tmp/nginx-${NGINX_VERSION} && \
  ./configure \
    --prefix=/usr/local/nginx \
    --add-module=/tmp/nginx-rtmp-module-${NGINX_RTMP_VERSION} \
    --conf-path=/etc/nginx/nginx.conf \
    --with-threads \
    --with-file-aio \
    --with-http_ssl_module \
    --with-debug \
    --with-cc-opt="-Wimplicit-fallthrough=0" && \
    make && make install

##########################
FROM alpine:3.12
LABEL MAINTAINER Thomas Woo <i@thomaswoo.com>

ENV HTTP_PORT 80
ENV HTTPS_PORT 443
ENV RTMP_PORT 1935

RUN set -ex && \
  apk add --update \
    ca-certificates \
    gettext \
    openssl \
    pcre \
    curl && \
  mkdir -p /opt/data && \
  mkdir /www

COPY --from=build-container /usr/local/nginx /usr/local/nginx
COPY --from=build-container /etc/nginx /etc/nginx

# Add NGINX path, config and static files.
ENV PATH "${PATH}:/usr/local/nginx/sbin"
ADD config/nginx.conf /etc/nginx/nginx.conf.template
ADD config/htpasswd_admin /etc/nginx/htpasswd_admin
ADD config/htpasswd_viewer /etc/nginx/htpasswd_viewer
ADD static /www/static

EXPOSE 80
EXPOSE 1935

CMD envsubst "$(env | sed -e 's/=.*//' -e 's/^/\$/g')" < \
  /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && \
  nginx
