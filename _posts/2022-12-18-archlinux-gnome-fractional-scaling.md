---
layout: post
title: Arch Linux GNOME 缩放 150%
date: 2022-12-18 19:49:00 +0800
---

安装 [mutter-x11-scaling](https://github.com/puxplaying/mutter-x11-scaling)

```shell
yay -S mutter-x11-scaling
```

启用 fractional scaling

```shell
gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"
```

注销，重新登陆。

设置 - 显示器 - 缩放 - 150%