ARG NGINX_VERSION=1.20.2
ARG NGINX_RTMP_VERSION=1.2.2

##############################
FROM alpine:3.14 as build-container
ARG NGINX_VERSION
ARG NGINX_RTMP_VERSION

RUN set -ex && \
  # Uncomment to accelerate with aliyun mirror if you are in Mainland China
  #sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
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
    --with-pcre \
    --with-poll_module \
    --with-file-aio \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-debug \
    --with-cc-opt="-Wimplicit-fallthrough=0" && \
    make && make install

##########################
FROM alpine:3.14
LABEL MAINTAINER Thomas Woo <i@thomaswoo.com>

ENV HTTP_PORT 80
ENV HTTPS_PORT 443
ENV RTMP_PORT 1935

RUN set -ex && \
  apk add --update \
    ca-certificates \
    gettext \
    openssl \
    pcre && \
  mkdir -p /opt/data && \
  mkdir /www

COPY --from=build-container /usr/local/nginx /usr/local/nginx
COPY --from=build-container /etc/nginx /etc/nginx

# Add NGINX path, config and static files.
ENV PATH "${PATH}:/usr/local/nginx/sbin"
ADD config/* /etc/nginx/
ADD static /www/static

EXPOSE 80
EXPOSE 1935

CMD envsubst "$(env | sed -e 's/=.*//' -e 's/^/\$/g')" < \
  /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && \
  nginx
