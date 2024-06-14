---
layout: post
title: Arch Linux (BIOS with MBR) 安装
date: 2020-04-10 13:45:00 +0800
---

确认主板系统是 [BIOS](https://zh.wikipedia.org/zh-cn/BIOS)，这里使用 [MBR](https://zh.wikipedia.org/zh-cn/主引导记录) 分区格式，关于究竟该使用 MBR 还是 GPT 请参考[这里](<https://wiki.archlinux.org/index.php/Partitioning_(简体中文)#选择_GPT_还是_MBR>)。

<!--excerpt-->

## 下载 Arch Linux 镜像

<https://www.archlinux.org/download/>

## 验证镜像完整性

```bash
md5 archlinux-2020.04.01-x86_64.iso
```

将输出和下载页面提供的 md5 值对比一下，看看是否一致，不一致则不要继续安装，换个节点重新下载直到一致为止。

## 镜像写入 U 盘

- Linux/Unix: dd

  用 lsblk 找到 U 盘并确保没有挂载，然后用 U 盘设备文件名替换 /dev/sdx，如 /dev/sdb，不要加上数字（不要键入 /dev/sdb1 之类的东西)

  ```bash
  dd bs=4M if=/path/to/archlinux.iso of=/dev/sdx status=progress && sync
  ```

  等待 sync 完成（所有数据都写入之后），然后拔掉 U 盘。

- MacOS: [balenaEtcher](https://github.com/balena-io/etcher)
- Windows: [USBWriter](https://sourceforge.net/projects/usbwriter/)

## 从 U 盘启动 Arch live 环境

在 BIOS 中设置启动磁盘为刚刚写入 Arch 系统的 U 盘

进入 U 盘的启动引导程序后，选择第一项：Boot Arch Linux (x86_64)

## 验证启动模式

```bash
ls /sys/firmware/efi/efivars
```

如果 /sys/firmware/efi/efivars 目录存在，那么系统应该是基于 UEFI 启动的，在主板设置里禁用 UEFI 模式启动。

## 连接 internet

- 查看连接

  ```bash
  ip link
  ```

- 连接

  对于有线网络，安装镜像启动的时候，默认会启动 dhcpcd，如果没有启动，可以手动启动：

  ```bash
  dhcpcd
  ```

- 验证连接

  ```bash
  ping shenyu.me
  ```

## 更新系统时间

```bash
timedatectl set-ntp true
```

## 磁盘分区

- 查看磁盘设备

  ```bash
  fdisk -l
  ```

- 新建分区表

  ```bash
  fdisk /dev/sda
  ```

  1. 输入 `o`，新建 DOS 分区表
  2. 输入 `w`，保存修改，这个操作会抹掉磁盘所有数据，慎重

- 分区创建

  1 扇区 = 512 字节

  ```bash
  fdisk /dev/sda
  ```

  1. 新建 Linux root 分区
     1. 输入 `n`
     2. 选择分区类型（p：主分区，e：扩展分区），默认选择 p ，直接 `Enter`
     3. 选择分区区号，直接 `Enter`，使用默认值，fdisk 会自动递增分区号
     4. 分区开始扇区号，直接 `Enter`，使用默认值
     5. 分区结束扇区号，这里要考虑预留给 swap 分区空间，计算公式：root 分区结束扇区号 = 磁盘结束扇区号 - 分配给 swap 分区的空间 (GB) \* 1024 \* 1024 \* 1024 / 512，输入后 `Enter`
     6. 输入 `t` 修改刚刚创建的分区类型
     7. 选择分区号，直接 `Enter`， 使用默认值，fdisk 会自动选择刚刚新建的分区
     8. 输入 `83`，使用 Linux 类型
  2. 新建 Linux swap 分区
     1. 输入 `n`
     2. 选择分区类型（p：主分区，e：扩展分区），默认选择 p ，直接 `Enter`
     3. 选择分区区号，直接 `Enter`，使用默认值，fdisk 会自动递增分区号
     4. 分区开始扇区号，直接 `Enter`，使用默认值
     5. 分区结束扇区号，直接 `Enter`，使用默认值
     6. 输入 `t` 修改刚刚创建的分区类型
     7. 选择分区号，直接 `Enter`， 使用默认值，fdisk 会自动选择刚刚新建的分区
     8. 输入 `82`，使用 Linux swap 类型
  3. 保存新建的分区
     1. 输入 `w`

## 磁盘格式化

- 格式化 Linux root 分区

  ```bash
  mkfs.ext4 /dev/sda1
  ```

  如果格式化失败，可能是磁盘设备存在 Device Mapper

  - 显示 dm 状态

    ```bash
    dmsetup status
    ```

  - 删除 dm

    ```bash
    dmsetup remove <dev-id>
    ```

- 格式化 Linux swap 分区

  ```bash
  mkswap /dev/sda2
  swapon /dev/sda2
  ```

## 挂载文件系统

```bash
mount /dev/sda1 /mnt
```

## 配置 pacman mirror

```bash
vim /etc/pacman.d/mirrorlist
```

所有安装的 package 其实是从 mirror 服务器上下载的，mirror 服务器的列表定义在 /etc/pacman.d/mirrorlist。  
mirror 被定义的位置越靠上面，被使用的优先级越高，所以根据地理位置信息，将最近的 mirror 移动至配置的最上面。  
这个配置之后会被 pacstrap 拷贝到安装的系统中，所以最好现在就配置一下。

## 安装必须的 Package

```bash
pacstrap /mnt base base-devel linux linux-firmware
```

之前版本 live system 中，linux 和 linux-firmware 包含在了 base 里了，最新的 live system 把这两个 package 从 base 中分离里出来，所以一定要手动指定。

想要安装其他 package 和 package group，可以将名字添加上面的 pacstrap 命令后面，或者在 arch-chroot 之后使用 pacman 来安装。live system 自带的 package 可以查看 [packages.x86_64](https://git.archlinux.org/archiso.git/tree/configs/releng/packages.x86_64)。

## 生成 fstab 文件

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

## 切换至安装好的 Arch

```bash
arch-chroot /mnt
```

## 设置时区

```bash
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
```

将 Region 和 City 替换成相应的洲和城市，例如：Asia/Shanghai

执行 hwclock 生成 /etc/adjtime：

```bash
hwclock --systohc
```

## 本地化

- 安装编辑器 vim，修改配置要使用

  ```bash
  pacman -S vim
  ```

- 修改 /etc/locale.gen，取消注释下面这两行配置

  ```text
  en_US.UTF-8 UTF-8
  zh_CN.UTF-8 UTF-8
  ```

- 生成 locale 信息

  ```bash
  locale-gen
  ```

- 创建 /etc/locale.conf

  ```bash
  LANG=en_US.UTF-8
  ```

## 网络配置

- 修改 hostname，创建 /etc/hostname

  ```text
  myhostname
  ```

- 配置 hosts，编辑 /etc/hosts

  ```text
  127.0.0.1 localhost
  ::1    localhost
  127.0.0.1 myhostname.localdomain myhostname
  ```

- 启动 dhcpcd 服务

  ```bash
  pacman -S dhcpcd
  systemctl enable dhcpcd
  ```

## 修改 root 密码

```bash
passwd
```

## 安装 Microcode

- AMD CPU

  ```bash
  pacman -S amd-ucode
  ```

- Intel CPU

  ```bash
  pacman -S intel-ucode
  ```

## 安装 GRUB

```bash
pacman -S grub
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```

## 安装图形界面

```bash
pacman -S gnome gnome-extra
systemctl enable gdm
```

## 安装 NetworkManager

```shell
pacman -S networkmanager
systemctl enable NetworkManager.service
```

## 新建用户

```bash
useradd -m <username>
passwd <username>
```

## 重新启动

```bash
exit    # 退出 chroot 环境
reboot
```

## 启动后需要设置的

- 开启时间自动同步

  ```bash
  timedatectl set-ntp true
  ```

- 安装 man page

  ```bash
  pacman -S man-db man-pages
  ```

- 安装配置 openssh

  ```bash
  pacman -S openssh
  systemctl start sshd
  systemctl enable sshd
  ```

- 配置 X11 转发

  ```bash
  pacman -S xorg-xauth
  ```

  ```conf
  # /etc/ssh/sshd_config

  X11Forwarding yes
  ```

- 安装 Yay

  ```bash
  pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si
  ```
