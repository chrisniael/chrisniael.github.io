---
layout: post
title: Arch Linux 应用程序图标显示不正确
date: 2022-06-28 23:06:00 +0800
---

Arch Linux，GNOME (Wayland) 桌面系统。

安装了几个桌面应用程序后，部分桌面应用程序的图标都显示成缺省的默认图标的了，而不是应用自己本身的图标。

```bash
sudo gtk-update-icon-cache -t -f /usr/share/icons/hicolor
```

执行后重启就好了。

## 参考

<http://wb-hk.blogspot.com/2016/09/archlinux-annoying-missing-icons.html>


