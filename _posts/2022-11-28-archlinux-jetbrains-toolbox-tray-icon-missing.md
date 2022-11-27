---
layout: post
title: Arch Linux (GNOME 桌面) JetBrains Toolbox 托盘图标不显示
date: 2022-11-28 00:27:00 +0800
---

安装 GNOME 扩展 [AppIndicator and KStatusNotifierItem Support](https://extensions.gnome.org/extension/615/appindicator-support/) 可以解决 GNOME 桌面部分应用不显示托盘的问题。

为了能安装 GNOME 扩展，需要安装 chrome-gnome-shell (浏览器扩展) 和 [gnome-browser-connector](https://aur.archlinux.org/packages/gnome-browser-connector)，具体可以参考[这里](https://wiki.gnome.org/Projects/GnomeShellIntegration/Installation)

以 Chrome 为例，首先安装 Chrome 扩展 [GNOME Shell 集成](https://chrome.google.com/webstore/detail/gnome-shell-integration/gphhapmejobijbbhgpjhcjognlahblep)，然后安装 [gnome-browser-connector](https://aur.archlinux.org/packages/gnome-browser-connector)

```bash
yay -S gnome-browser-connector
```

安装 GNOME 扩展的准备工作做好后，打开 [AppIndicator and KStatusNotifierItem Support](https://extensions.gnome.org/extension/615/appindicator-support/) 扩展的主页，点击 **Install** 来安装。

安装完成后，在 **扩展** 应用里启用 **AppIndicator and KStatusNotifierItem Support**，然后 Jetbrains Toolbox 的托盘图标应该就显示了。
