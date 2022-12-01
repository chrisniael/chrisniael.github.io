---
layout: post
title: Arch Linux (GNOME 桌面) JetBrains Toolbox 托盘图标不显示
date: 2022-11-28 00:27:00 +0800
---

安装 GNOME 扩展 [AppIndicator and KStatusNotifierItem Support](https://extensions.gnome.org/extension/615/appindicator-support/)

```bash
sudo pacman -S gnome-shell-extension-appindicator
```


安装完成后，在 **扩展** 应用里启用 **AppIndicator and KStatusNotifierItem Support**。

然后原先不显示托盘图标的应用就能显示图标了，包括 Remmina、Telegram 等，但是 JetBrains Toolbox 的托盘图标并没有正常显示。

重启几次 JetBrains Toolbox 后发现，JetBrains Toolbox 刚打开那刻托盘图标会显示一下，然后不到 1 秒就消失不见了，检查 Toolbox 的日志并没有发现什么有用的报错信息（关于 - 显示日志文件），只能等 JetBrains 官方修复了。
