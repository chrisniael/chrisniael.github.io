---
layout: post
title: Arch Linux (UEFI with GPT) 安装
date: 2020-04-11 20:15:00 +0800
---

确认主板系统是 [UEFI](https://zh.wikipedia.org/zh-cn/BIOS)，这里使用 [GPT](https://zh.wikipedia.org/wiki/GUID磁碟分割表) 分区格式，关于究竟该使用 MBR 还是 GPT 请参考[这里](https://wiki.archlinux.org/index.php/Partitioning_(简体中文)#选择_GPT_还是_MBR)。

<!--excerpt-->

## 下载 Arch Linux 镜像

<https://www.archlinux.org/download/>

## 验证镜像完整性

```bash
md5 archlinux-2020.04.01-x86_64.iso
```

将输出和下载页面提供的 md5 值对比一下，看看是否一致，不一致则不要继续安装，换个节点重新下载直到一致为止。

## 镜像写入 U 盘

* Linux/Unix: dd

  用 lsblk 找到 U 盘并确保没有挂载，然后用 U 盘设备文件名替换 /dev/sdx，如 /dev/sdb，不要加上数字（不要键入 /dev/sdb1 之类的东西)

  ```bash
  dd bs=4M if=/path/to/archlinux.iso of=/dev/sdx status=progress && sync
  ```

  等待 sync 完成（所有数据都写入之后），然后拔掉 U 盘。

* MacOS: [balenaEtcher](https://github.com/balena-io/etcher)
* Windows: [USBWriter](https://sourceforge.net/projects/usbwriter/)

## 从 U 盘启动 Arch live 环境

在 UEFI BIOS 中设置启动磁盘为刚刚写入 Arch 系统的 U 盘。

进入 U 盘的启动引导程序后，选择第一项：Arch Linux archiso x86_64 UEFI CD

## 验证启动模式

```bash
ls /sys/firmware/efi/efivars
```

如果 /sys/firmware/efi/efivars 目录不存在，则系统可能是从 BIOS 模式启动的。参考 *Arch Linux (UEFI with GPT) 安装*。

## 连接 internet

* 查看连接

  ```bash
  ip link
  ```

* 连接

  对于有线网络，安装镜像启动的时候，默认会启动 dhcpcd，如果没有启动，可以手动启动：

  ```bash
  dhcpcd
  ```

* 验证连接

  ```bash
  ping shenyu.me
  ```

## 更新系统时间

```bash
timedatectl set-ntp true
```

## 磁盘分区

* 查看磁盘设备

  ```bash
  fdisk -l
  ```

* 新建分区表

  ```bash
  fdisk /dev/nvme0n1
  ```

  1. 输入 `g`，新建 GPT 分区表
  2. 输入 `w`，保存修改，这个操作会抹掉磁盘所有数据，慎重

* 分区创建

  1 扇区 = 512 字节

  ```bash
  fdisk /dev/nvme0n1
  ```

  1. 新建 EFI System 分区
     1. 输入 `n`
     2. 选择分区区号，直接 `Enter`，使用默认值，fdisk 会自动递增分区号
     3. 分区开始扇区号，直接 `Enter`，使用默认值
     4. 分区结束扇区号，输入 `+512M`（推荐大小）
     5. 输入 `t` 修改刚刚创建的分区类型
     6. 选择分区号，直接 `Enter`， 使用默认值，fdisk 会自动选择刚刚新建的分区
     7. 输入 `1`，使用 EFI System 类型
  2. 新建 Linux root (x86-64)  分区
     1. 输入 `n`
     2. 选择分区区号，直接 `Enter`，使用默认值，fdisk 会自动递增分区号
     3. 分区开始扇区号，直接 `Enter`，使用默认值
     4. 分区结束扇区号，这里要考虑预留给 swap 分区空间，计算公式：root 分区结束扇区号 = 磁盘结束扇区号 - 分配给 swap 分区的空间 (GB) \* 1024 \* 1024 \* 1024 / 512，输入后 `Enter`
     5. 输入 `t` 修改刚刚创建的分区类型
     6. 选择分区号，直接 `Enter`， 使用默认值，fdisk 会自动选择刚刚新建的分区
     7. 输入 `24`，使用 Linux root (x86-64) 类型
  3. 新建 Linux swap 分区
     1. 输入 `n`
     2. 选择分区区号，直接 `Enter`，使用默认值，fdisk 会自动递增分区号
     3. 分区开始扇区号，直接 `Enter`，使用默认值
     4. 分区结束扇区号，比如 `+8G`
     5. 输入 `t` 修改刚刚创建的分区类型
     6. 选择分区号，直接 `Enter`， 使用默认值，fdisk 会自动选择刚刚新建的分区
     7. 输入 `19`，使用 Linux swap 类型
  4. 保存新建的分区
     1. 输入 `w`

## 磁盘格式化

* 格式化 EFI System 分区

  ```bash
  mkfs.fat -F32 /dev/nvme0n1p1
  ```

  如果格式化失败，可能是磁盘设备存在 Device Mapper

  * 显示 dm 状态

    ```bash
    dmsetup status
    ```

  * 删除 dm

    ```bash
    dmsetup remove <dev-id>
    ```

* 格式化 Linux root 分区

  ```bash
  mkfs.ext4 /dev/nvme0n1p2
  ```

* 格式化 Linux swap 分区

  ```bash
  mkswap /dev/nvme0n1p3
  swapon /dev/nvme0n1p3
  ```

## 挂载文件系统

```bash
mount /dev/nvme0n1p2 /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```

## 配置 pacman mirror

```bash
vim /etc/pacman.d/mirrorlist
```

## 安装 Arch 和 Package Group

```bash
pacstrap /mnt base base-devel linux linux-firmware
```

## 生成 fstab 文件

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

## 切换至安装好的 Arch

```bash
arch-chroot /mnt
```

## 本地化

* 安装编辑器 vim，下面修改配置需要使用

  ```bash
  pacman -S vim
  ```

* 修改 /etc/locale.gen，取消注释下面这两行配置

  ```bash
  en_US.UTF-8 UTF-8
  zh_CN.UTF-8 UTF-8
  ```

* 生成 locale 信息

  ```bash
  locale-gen
  ```

* 创建 /etc/locale.conf

  ```text
  LANG=en_US.UTF-8
  ```

## 网络配置

* 修改 hostname，编辑 /etc/hostname

  ```text
  myhostname
  ```

* 配置 hosts，编辑 /etc/hosts

  ```text
  127.0.0.1 localhost
  ::1    localhost
  127.0.1.1 myhostname.localdomain myhostname
  ```

* 启动 dhcpcd 服务

  ```bash
  pacman -S dhcpcd
  systemctl enable dhcpcd
  ```

## 修改 root 密码

```bash
passwd
```

## 安装 Microcode

* AMD CPU

  ```bash
  pacman -S amd-ucode
  ```

* Intel CPU

  ```bash
  pacman -S intel-ucode
  ```

## 安装 GRUB

```bash
pacman -S grub
pacman -S efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg
```

## 安装图形界面

```bash
pacman -S gnome gnome-extra
systemctl enable gdm
```

## 重新启动

```bash
exit    # 退出 chroot 环境
reboot
```

## 启动后需要设置的

* 开启时间自动同步

  ```bash
  timedatectl set-ntp true
  timedatectl set-timezone Asia/Shanghai
  hwclock --systohc
  ```

* 安装配置 openssl

  ```bash
  pacman -S openssl
  systemctl start sshd
  systemctl enable sshd
  ```

* 配置 X11 转发

  ```bash
  pacman -S xorg-xauth
  ```

  ```conf
  # /etc/ssh/sshd_config

  X11Forwarding yes
  ```

* 新建用户

  ```bash
  useradd -m <username>
  ```

* 一些常用的软件

  ```bash
  pacman -S zsh git tmux python python-pip xsel wget nodejs npm clang ripgrep \
      man-db man-pages texinfo cmake protobuf hiredis htop gperftools \
      screenfetch unzip inetutils mariadb-libs zip boost net-tools ruby gdb
  pip install pynvim
  pip install cpplint
  npm install -g neovim bash-language-server

  ```
