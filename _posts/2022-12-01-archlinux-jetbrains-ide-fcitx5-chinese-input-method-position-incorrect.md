---
layout: post
title: Arch Linux (GNOME 桌面) JetBrains IDE Fcitx5 中文输入法位置显示不正确
date: 2022-12-01 22:42:00 +0800
---

下载修复好的 [JetBrainsRuntime](https://github.com/RikudouPatrickstar/JetBrainsRuntime-for-Linux-x64/releases/latest) 并解压至 `~/.jbr` 目录

```shell
wget https://github.com/RikudouPatrickstar/JetBrainsRuntime-for-Linux-x64/releases/download/jbr-release-17.0.4b469.46/jbr_jcef-17.0.4-linux-x64-b469.46.tar.gz
tar xvf jbr_jcef-17.0.4-linux-x64-b469.46.tar.gz
mv jbr_jcef-17.0.4.1-linux-x64-b653.1 ~/.jbr
```

添加下面的配置至 `~/.xprofile`

```shell
JET_BRAINS_IDES=(
  CLION
  DATAGRIP
  GOLAND
  IDEA
  MPS
  PHPSTORM
  PYCHARM
  RIDER
  RUBYMINE
  WEBIDE
)

for IDE in "${JET_BRAINS_IDES[@]}"; do
  export ${IDE}_JDK=${HOME}/.jbr
done
```

注销 GNOME 桌面，重新登陆。

注意：如果设置了缩放显示，那么位置还是会不正确，这个开源的 patch 暂时只支持 100% 缩放的情况正确显示输入法位置。
