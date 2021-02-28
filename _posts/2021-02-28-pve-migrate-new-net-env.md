---
layout: post
title: Proxmox VE 迁移新的网络环境
date: 2021-02-28 16:52:00 +0800
---

[Proxmox VE](https://pve.proxmox.com/wiki/Main_Page) （下文简单称其为 PVE）迁移到新的网络环境时，IP、网关 和 DNS 都可能会随之变化。需要对 PVE 做一些配置上的更改来适应新的环境，以保证服务能正常工作。

假设我们新的网络环境为：

- 网段： 10.0.0.1-10.0.0.255

  在这个范围内找一个还未使用的 IP 作为 PVE 的 IP，这里我们使用 10.0.0.200。

- 子网掩码：255.255.255.0
- 网关：10.0.0.1
- DNS：10.0.0.1

一般网关和 DNS 都是当前网络环境的路由器的 IP 地址。

将 PVE 的宿主机接上显示器和键盘，开机。

## 修改 IP 地址

编辑 `/etc/network/interfaces`。

```text
auto lo
iface lo inet loopback

iface enp3s0 inet manual

auto vmbr0
iface vmbr0 inet static
        address 10.0.0.200
        netmask 255.255.255.0
        gateway 10.0.0.1
        bridge_ports enp3s0
        bridge_stp off
        bridge_fd 0

iface enp5s0 inet manual
```

网络设备名每台机器可能会略有不同，忽略，修改 `address`, `netmask` 和 `gateway` 字段对应的值为新环境的网络地址。

## 修改终端提示地址

编辑 `/etc/issue`。

```text
------------------------------------------------------------------------------

Welcome to the Proxmox Virtual Environment. Please use your web browser to
configure this server - connect to:

  https://10.0.0.200:8006/

------------------------------------------------------------------------------
```

`/etc/issue` 的内容是 Linux 终端登启动后的欢迎语句。将 URL 中的 IP 地址更改 PVE 新的 IP，之后就可以通过这个 URL 访问 PVE 管理后台。

## 修改 hosts

编辑 `/etc/hosts`。

```text
127.0.0.1 localhost.localdomain localhost
10.0.0.200 pve.lan pve
```

将 `pve.lan` （局域网 hostname）映射的 IP 更换成 PVE 新的 IP 地址。

## 修改 DNS

编辑 `/etc/resolv.conf`。

```text
nameserver 10.0.0.1
```

## 重启

上述所有配置都修改完后，重启 PVE 宿主机就可以使配置生效了。

```bash
reboot
```
