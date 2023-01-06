---
layout: post
title: x86-64 设备安装配置 OpenWRT
date: 2021-02-26 01:14:00 +0800
---

OpenWRT 的安装过程本质上来说就是将 OpenWRT 系统镜像写入软路由的硬盘里。这里使用 Finnix 系统来将 OpenWRT 安装进 X86-64
的设备中，要使用到的一些设备：

- 安装了 Finnix 系统的 U 盘 1 个。
- 网线 2 根。
- 1 个能插网线上网的环境。
- 显示器 1 台。
- HDMI 线 1 根（取决于软路由提供的视频输出接口）。
- PC 1 台。

这里假设软路由设备有 4 个 网口，分别为：LAN1， LAN2， LAN3 和 LAN4，下文会用到。

## 安装 Finnix 至 U 盘

从 <https://www.finnix.org> 下载最新的 Finnix 系统镜像，然后将其写入 U 盘。

- Windows
    - [Rufus](https://rufus.ie)
- Mac
    - [Etcher](https://www.balena.io/etcher/)
- Linux
    - dd

      ```bash
      dd if=finnix-124.iso of=/dev/sdX
      ```

## 安装 OpenWRT

将软路由设备的 LAN2 接上能自动分配 IP 并能上网的网线，将 Finnix U 盘插在软路由 USB 口上，然后开机，从 U 盘启动（关于这点自行
Google）进入 Finnix 系统。

下载并解压 OpenWRT 最新的系统文件。

<https://downloads.openwrt.org>

官方提供了多种格式的 Image Files

- combined-ext4.img.gz：包含引导信息、rootfs(ext4 格式)、内核以及相关分区信息的硬盘镜像，可以 dd 写入某个磁盘。
- combined-squashfs.img.gz：包含引导信息、rootfs(squashfs 格式)、内核以及相关分区信息的硬盘镜像。
- generic-rootfs.tar.gz：rootfs 包含的所有文件。
- rootfs-ext4.img.gz：rootfs(ext4 格式) 分区镜像，可以 dd 到某个分区或者 mount -o 到某个目录。
- rootfs-squashfs.img.gz：rootfs(squashfs 格式) 分区镜像，可以 dd 写入某个分区或者 mount -o 挂载到目录。
- vmlinuz：内核

ext4 与 squashfs 格式的区别：

- ext4 格式的 rootfs 可以扩展磁盘空间大小，而 squashfs 不能。
- squashfs 格式的 rootfs 可以使用重置功能（恢复出厂设置），而 ext4 不能。

我们这里选择 combined-ext4.img.gz。

```bash
wget https://downloads.openwrt.org/releases/19.07.7/targets/x86/64/openwrt-19.07.7-x86-64-combined-ext4.img.gz
gzip -d openwrt-19.07.7-x86-64-combined-ext4.img.gz
```

通过 `lsblk` 命令确认哪个设备名是软路由的硬盘。

```bash
NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
loop0 7:0 0 342.6M 1 loop /usr/lib/live/mount/rootfs/filesystem.squashfs
sda 8:0 0 14.9G 0 disk
sdb 8:16 1 7.5G 0 disk
├─sdb1 8:17 1 411M 0 part /usr/lib/live/mount/medium
└─sdb2 8:18 1 2.9M 0 part
zram0 253:0 0 1.9G 0 disk [SWAP]
```

可以根据 SIZE 大小判断，这里 `sda` 是软路由的硬盘。

将 OpenWRT 系统镜像写入 `sda` 标识的硬盘里。

```bash
dd if=openwrt-19.07.7-x86-64-combined-ext4.img bs=1M of=/dev/sda
```

## OpenWRT 系统空间扩容

通过 `lsblk` 命令查看目前磁盘划分情况。

```bash
NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
loop0 7:0 0 342.6M 1 loop /usr/lib/live/mount/rootfs/filesystem.squashfs
sda 8:0 0 14.9G 0 disk
├─sda1 8:1 0 16M 0 part
└─sda2 8:2 0 256M 0 part
sdb 8:16 1 7.5G 0 disk
├─sdb1 8:17 1 411M 0 part /usr/lib/live/mount/medium
└─sdb2 8:18 1 2.9M 0 part
zram0 253:0 0 1.9G 0 disk [SWAP]
```

可以看到 sda 磁盘仅仅分了 2 个区，且 2 个区总空间才 200 多 MB。sda1 是引导分区，sda2 是 OpenWRT 的系统分区，这里只要将磁盘剩余没有使用上的空间追加到
sda2 分区上就可以了。

使用 `fdisk` 重新分配 sda2 分区大小。

```bash
root@0:~# fdisk /dev/sda

Welcome to fdisk (util-linux 2.36.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Command (m for help): p
Disk /dev/sda: 14.91 GiB, 16013852672 bytes, 31277056 sectors
Disk model: IM016-S220
Units: sectors of 1 \* 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xeb3ae1bb

Device Boot Start End Sectors Size Id Type
/dev/sda1 \* 512 33279 32768 16M 83 Linux
/dev/sda2 33792 558079 524288 256M 83 Linux

Command (m for help): d
Partition number (1,2, default 2): 2

Partition 2 has been deleted.

Command (m for help): n
Partition type
p primary (1 primary, 0 extended, 3 free)
e extended (container for logical partitions)
Select (default p):

Using default response p.
Partition number (2-4, default 2):
First sector (33280-31277055, default 34816): 33792
Last sector, +/-sectors or +/-size{K,M,G,T,P} (33792-31277055, default 31277055):

Created a new partition 2 of type 'Linux' and of size 14.9 GiB.
Partition #2 contains a ext4 signature.

Do you want to remove the signature? [Y]es/[N]o: N

Command (m for help): w

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

这里注意删除分区 2 后，新建分区的 First sector 不能用 **默认值** (34816)，得输入删除前的 First sector 值 (**33792**)。

增大 sda2 文件系统大小。

```bash
resize2fs /dev/sda2
```

最后重启，OpenWRT 就安装完成了。

```bash
reboot
```

## 配置 OpenWRT

### 登录 LuCI 管理后台

openwrt 默认 LAN2（eth1） 为 wan 口，LAN1（eth0） 位 lan 口。

![](/assets/2021-02-26-x86-64-install-openwrt-link-illustrate.png)

- 将 LAN2 口插入能自动分配 IP 且能上网的网线。
- 将 LAN1 口与电脑通过网线连接
- 在浏览器输入 192.168.1.1 访问 luci 管理后台
- 用户名为 root，默认没有设置密码的，密码不用输入，直接点 Login。

这里先不更改 WAN 口默认的协议，直接使用默认的 DHCP 客户端模式，等后续所有配置设置完成后，最后更改，然后替换现有的路由器。

### LuCI 中文界面

- System - Software
- 点击 **Update lists**
- 在 **Filter** 里输入 `luci-i18n-base-zh-cn`
- 点击筛选结果列表里 `luci-i18n-base-zh-cn` 后面的 **Install**

安装完成后，刷新一下当前网页就能看到中文的操作界面了。

### 设置 LuCI 登录密码

- 系统 - 管理权 - 主机密码
- 密码
- 确认密码
- 保存

这个密码既是 root 用户的 LuCI 登录密码，也是 root 用户的 ssh 登录密码。

### 修改时区

- 系统 - 系统 - 系统属性 - 常规设置
- 时区: Asia/Shanghai
- 保存并应用

### 更换 WAN 口位置

openwrt 默认 LAN2（eth1） 为 WAN 口，LAN1（eth0）为 LAN 口，将 WAN 口更改为 LAN1（eth0）。

设备名与 LAN 物理接口名的对应关系：

- eth0: LAN1
- eth1: LAN2
- eth2: LAN3
- eth3: LAN4

- 设置 LAN 为 eth1。
    - 网络 - 接口 - LAN - 编辑 - 物理设置
    - 接口: eth1
    - 保存
- 设置 WAN 口为 eth0。
    - 网络 - 接口 - WAN - 编辑 - 物理设置
    - 接口：eth0
    - 保存
- 保存并应用

![](/assets/2021-02-26-x86-64-install-openwrt-exchange-wan-illustrate.png)

### 桥接所有 LAN 口

openwrt 默认只设置了 LAN2（eth1）和 LAN1（eth0）接口，其余物理 LAN 口暂未设置，桥接 LAN2（eth1）与剩余所有 LAN 口。

- 网络 - 接口 - LAN - 编辑 - 物理设置
- 接口：将除了 eth0 (wan) 以外所有适配器都选择上。
- 保存
- 保存并应用

### 禁用 IPv6

- 关闭 LAN 口分配 IPv6 IP。
    - 网络 - 接口 - LAN - 编辑 - 常规设置
    - IPv6 分配长度：已禁用
    - 保存
- 关闭 IPv6 DHCP
    - 网络 - 接口 - LAN - 编辑 - DHCP 服务器 - IPv6 设置
    - 路由通告服务：已禁用
    - DHCPv6 服务：已禁用
    - 保存
- 关闭 IPv6 WAN 口
    - 网络 - 接口 - WAN6
    - 停止
- 禁止 IPv6 WAN 功能自动启动
    - 网络 - 接口 - WAN6 - 编辑 - 常规设置
    - 开机自动运行：取消勾选
    - 保存
- 保存并应用

### 替换现有路由器

更改 OpenWRT WAN 口协议，与现有路由器保持一致。目前普通家庭宽带上网的模式都有：

- 猫设置成路由模式，既拨号又充当路由器，电信目前最新的猫都带路由功能且有 WiFi，默认是这种方式。

  这种方式的话，OpenWRT 不用更改 WAN 口协议，默认的 DHCP 客户端模式就可以，但是可能要更改一下 LAN 口的网段，确保别和猫的 LAN
  口网段冲突。

    - 网络 - 接口 - LAN - 编辑 - 常规设置
        - IPv4 地址：根据实际情况填写，10.0.0.1 或 172.16.0.1 或 192.168.1.1
        - IPv4 子网掩码：根据实际情况填写，255.255.255.0
    - 保存并应用

  LAN 口 IPv4 地址更改后，LuCI 的登录地址也会对应变成更改后的地址。

- 猫设置为桥接模式，路由器来拨号。（推荐）

  需要将 OpenWRT 的 WAN 口协议更改为 PPPoE，并填写宽带运营商提供的账号密码。

    - 网络 - 接口 - WAN - 编辑 - 常规设置
        - 协议：PPPoE
        - 确定要切换协议？：切换协议
        - PAP/CHAP 用户名：宽带运营商提供的账号
        - PAP/CHAP 密码：宽带运营商提供的密码
        - 保存
    - 保存并应用

## 其他

### 升级所有可以更新的软件

```bash
opkg upgrade $(opkg list-upgradable | awk '{print $1}')
```

### wget/curl/opkg 支持 https

```bash
opkg update
opkg install libustream-openssl ca-bundle ca-certificates
```

### luci(uHTTPd) 启用 https

https://openwrt.org/docs/guide-user/luci/getting_rid_of_luci_https_certificate_warnings

```bash
opkg update
opkg install openssl-util luci-app-uhttpd
```

LuCI 退出重新登录一下，然后就能在 **服务** 里看到 **uHTTPd** 选项了。

### luci uHTTPd 中文支持

```
opkg update
opkg install luci-i18n-uhttpd-zh-cn
```

### Package 镜像修改为国内源

<https://mirrors.tuna.tsinghua.edu.cn/help/openwrt/>

```bash
sed -i 's_downloads.openwrt.org_mirrors.tuna.tsinghua.edu.cn/openwrt_' /etc/opkg/distfeeds.conf
```

### 默认 Shell 改用 bash

默认为 ash

```bash
opkg install bash
vim /etc/passwd
root:x:0:0:root:/root:/usr/bin/bash
```

### Package size mismatch

```bash
opkg --force-checksum install <pkg>
```
