# shenyu.me

[https://shenyu.me](https://shenyu.me)

我的博客，使用 [Jekyll](https://github.com/jekyll/jekyll) 生成，基于 [minima](https://github.com/jekyll/minima) 主题。

## ruby 开发环境

* ruby >= 2.4
* gem
* gcc & g++
* make

暂时别使用最新的 ruby 2.7，构建的时候会报语法错误。

## 安装依赖

```bash
gem install bundler
bundle install
# bundle update  # 更新的话
```

## 生成网站

```bash
bundle exec jekyll build
```
