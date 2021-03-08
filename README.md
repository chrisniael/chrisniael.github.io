# shenyu.me

[https://shenyu.me](https://shenyu.me)

我的博客，使用 [Jekyll](https://github.com/jekyll/jekyll) 生成，基于 [minima](https://github.com/jekyll/minima) 主题。

## 使用

确保已经安装 docker。

```bash
docker pull jekyll/jekyll:3.8.6
docker run \
  --volume="$PWD:/srv/jekyll" \
  --name jekyll-server \
  -d \
  -p 4000:4000 \
  jekyll/jekyll:3.8.6 \
  jekyll serve --watch --incremental
```

通过 docker 日志查看 jekyll 是否初始化成功。

```bash
docker logs -f jekyll-server
```

初始化成功后就可以浏览器打开 <http://127.0.0.1:4000> 预览网站了。容器启动后，可以继续编辑网站内容，刷新一下网页可以预览更新后的内容。

如果容器的宿主机重启了，jekyll-server 容器会处于关闭状态，想要继续使用它预览网站的话，可以直接 start jekyll-server 容器。

```bash
docker start jekyll-server
```
