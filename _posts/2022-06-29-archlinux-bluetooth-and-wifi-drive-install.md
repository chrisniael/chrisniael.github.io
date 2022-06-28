---
layout: post
title: Arch Linux 安装蓝牙和 Wi-Fi 驱动
date: 2022-06-29 01:20:00 +0800
---

Arch Linux，GNOME (Wayland) 桌面系统，主板型号：ROG ZENITH EXTREME。

## 蓝牙

```bash
su -
pacman -S bluez
pacman -S bluez-utils
systemctl start bluetooth.service
systemctl enable bluetooth.service
```

设置 - 蓝牙

右上角打开蓝牙的开关，然后就可以搜索到要连接的设备了。

## Wi-Fi

```bash
su -
pacman -S networkmanager
systemctl start NetworkManager.service
systemctl enable NetworkManager.service
```

## 参考

- <https://wiki.archlinux.org/title/Bluetooth_(简体中文)>
- <https://wiki.archlinux.org/title/NetworkManager_(简体中文)>
