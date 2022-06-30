---
layout: post
title: Arch Linux 安装蓝牙和 Wi-Fi 驱动
date: 2022-06-29 01:20:00 +0800
---

Arch Linux，GNOME (Wayland) 桌面系统，主板型号：ROG ZENITH EXTREME。

## 蓝牙

### 安装

```bash
su -
pacman -S bluez
pacman -S bluez-utils
systemctl start bluetooth.service
systemctl enable bluetooth.service
```

### 开机自动打开蓝牙

/etc/bluetooth/main.conf

```text
[Policy]
AutoEnable=true
```

### 蓝牙耳机/音响

```bash
su -
pacman -S pulseaudio-bluetooth
```

连接上设备后自动切换输出源至新连接上的设备

/etc/pulse/system.pa

```text
load-module module-bluetooth-policy
load-module module-bluetooth-discover
load-module module-switch-on-connect
```

将当前用户添加至 `lp` 用户组中

```bash
sudo usermod -aG docker $USER
```

重启生效。

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
