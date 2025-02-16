---
layout: post
title: Arch Linux 安装蓝牙和 Wi-Fi 驱动
date: 2022-06-29 01:20:00 +0800
---

Arch Linux，GNOME 桌面环境，主板型号：ROG ZENITH EXTREME。

## 蓝牙

[bluez](https://archlinux.org/packages/?name=bluez) 包系统默认会安装，无需再手动安装，这个包提供蓝牙协议栈，但是默认没有设置它的服务自动启动，这里需要手动设置并启动一下。

### 启动蓝牙服务

```bash
su -
pacman -S bluez  ## 最新版本 Arch Linux 默认已安装
systemctl enable --now bluetooth.service
```

### 开机自动打开蓝牙

/etc/bluetooth/main.conf

```text
[Policy]
AutoEnable=true
```

### 蓝牙音频服务

最新版本 Arch Linux 已经使用 [PipeWire](https://wiki.archlinuxcn.org/wiki/PipeWire) 替代 [PulseAudio](https://wiki.archlinuxcn.org/wiki/PulseAudio)，且默认已经安装，且无需做再多的配置就能正常工作。

## Wi-Fi

```bash
su -
pacman -S networkmanager
systemctl start NetworkManager.service
systemctl enable NetworkManager.service
```

## 参考

- [Bluetooth](https://wiki.archlinux.org/title/Bluetooth_(简体中文)), wiki.archlinux.org
- [NetworkManager](https://wiki.archlinux.org/title/NetworkManager_(简体中文)), wiki.archlinux.org
