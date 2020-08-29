# docker-nginx-rtmp

Docker build file for nginx with nginx-rtmp-module. Act as a rtmp &amp; hls streaming server. Based on Alpine Linux.

* Nginx 1.18.0
* nginx-rtmp-module 1.2.1

## Usage

### Server
* Pull docker image and run a test flight :
```
docker pull thomaswoo/nginx-rtmp
docker run -it --rm -p 1935:1935 -p 8080:80 thomaswoo/nginx-rtmp
```
or build it by yourself :
```
docker build -t nginx-rtmp .
docker run -it --rm -p 1935:1935 -p 8080:80 nginx-rtmp
```
* If the test flight runs well, start a daemon :
```
docker run -itd -p 1935:1935 -p 8080:80 --name nginx-rtmp-server --restart=always thomaswoo/nginx-rtmp
```

### Start Stream
* Push an rtmp stream to :
```
rtmp://<server_ip>:1935/stream/<stream_name>
```

### Watch Stream
* Watch RTMP stream at :
```
rtmp://<server_ip>:1935/stream/<stream_name>
```
* Watch HLS/m3u8 stream at :
```
http://<server_ip>:8080/live/<stream_name>.m3u8
```

### Check Stream Status
* Open link in browser:
```
http://<server_ip>:8080/stat
```
The default username/password is admin/admin.

Change username/password by create a new htpasswd file and mount to : `/etc/nginx/htpasswd_admin`

## Reference
* https://alpinelinux.org/
* http://nginx.org
* https://github.com/arut/nginx-rtmp-module
* https://obsproject.com/
