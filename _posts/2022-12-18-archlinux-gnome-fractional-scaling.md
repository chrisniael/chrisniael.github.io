---
layout: post
title: Arch Linux GNOME 启用分数缩放
date: 2022-12-18 19:49:00 +0800
---

Arch Linux，GNOME 43.2 在 4K 分辨率下默认只能缩放 100%、200% 或 300% 这三个选项，100% 字太小，200% 字又太大。

安装 [mutter-x11-scaling](https://github.com/puxplaying/mutter-x11-scaling) 来启用 GNOME 的分数缩放功能

```shell
yay -S mutter-x11-scaling
```

打开 GNOME 的 fractional scaling 功能

```shell
gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"
```

注销，重新登陆。

设置 - 显示器 - 缩放 - 150%
