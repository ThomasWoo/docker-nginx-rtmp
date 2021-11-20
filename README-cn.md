# docker-nginx-rtmp

Docker build file for nginx with nginx-rtmp-module. Act as a rtmp &amp; hls streaming server. Based on Alpine Linux.

Nginx + nginx-rtmp-module 模块的 Dockerfile，用于搭建 rtmp + hls 流媒体服务器。基于 Alpine Linux。

[Doc in English](README.md)

* Nginx 1.20.2
* nginx-rtmp-module 1.2.2

## 用法

### 服务器端
* 从 Dockerhub 拉取镜像并测试 ：
```
docker pull thomaswoo/nginx-rtmp
docker run -it --rm -p 1935:1935 -p 8080:80 thomaswoo/nginx-rtmp
```
或者自行构建并运行测试 ：
```
docker build -t nginx-rtmp .
docker run -it --rm -p 1935:1935 -p 8080:80 nginx-rtmp
```
* 如果测试没有问题，就可以启动后台运行 ：
```
docker run -itd -p 1935:1935 -p 8080:80 --name nginx-rtmp-server --restart=always thomaswoo/nginx-rtmp
```
* 加载自己的配置文件模板 ：
```
docker run -itd -p 1935:1935 -p 8080:80 -v /path/to/nginx.conf:/etc/nginx/nginx.conf.template --name nginx-rtmp-server --restart=always thomaswoo/nginx-rtmp
```
* 设置 hls 播放路径的 autoindex ：
```
docker run -itd -p 1935:1935 -p 8080:80 -e HLS_AUTO_INDEX=on --name nginx-rtmp-server --restart=always thomaswoo/nginx-rtmp
```

### 推流
* 将 rtmp 视音频流推送到以下地址 ：
```
rtmp://<server_ip>:1935/stream/<stream_name>
```

### 收看
* 从以下地址收看 rtmp 视音频流 ：
```
rtmp://<server_ip>:1935/stream/<stream_name>
```
* 从以下地址收看 HLS/m3u8 视音频流 ：
```
http://<server_ip>:8080/live/<stream_name>.m3u8
```

### 检查推流状态
* 在浏览器中打开以下地址
```
http://<server_ip>:8080/stat
```
默认的账户/密码是：admin/admin

如果需要更改账户、密码，创建一个新的 htpasswd 文件，并挂载到以下位置：`/etc/nginx/htpasswd_admin`。

## 参考
* https://alpinelinux.org/
* https://nginx.org
* https://github.com/arut/nginx-rtmp-module
* https://obsproject.com/
