---
layout: post
title: Mac 与 Windows 鼠键共用方案
date: 2021-02-08 20:54:00 +0800
---

有同时使用 Mac 和 Windows 的需求，Mac 主，Windows 从，但这样子需要使用 2 套鼠标键盘来分别控制 Mac 和 Windows，所有就探索一下现有的一些解决方案，实现在 Mac 与 Windows 之间共用同一套鼠标键盘，暂时没有找到很完美的，下面记录了一下各自的优缺点。

## Synergy

<https://github.com/symless/synergy-core>

开源版本需要自己编译，暂时没有试用。

## Barrier

<https://github.com/debauchee/barrier>

Fork 自 Synergy 开源版本，共用鼠标键盘的核心功能以及同步剪切板内容的功能正常使用。

缺点：

- 文件拖拽传输功能暂时不能用。
- Server 端输入法状态为中文时，切换至 Client 端屏幕，此时大部分标点符号无法输入。
- UAC 弹出/消失时会鼠标会跳回 Server 端。

## SANWA KB-USB-LINK5

适合 Windows 作为主，Mac 为从设备的用户。

缺点：

- 需要花银子买一根硬件数据线，价格 300 多块，不算便宜。
- Mac 上，需要自己手动更改安装后的 App 的可执行文件的可执行权限才能使用。

  ```bash
  chmod a+x /Applications/SmartDataLink.app/Contents/MacOS/SmartDataLinkShell
  ```

- Mac 主，Windows 从，Windows 键盘重复输入时卡顿，反过来使用没有卡顿问题。
- 仅使用快捷键切换屏幕功能有 bug，用鼠标依旧可以移动至另一个屏幕。

## ShareMouse

<https://www.sharemouse.com>

能调节远端鼠标的 DPI 和鼠标滚轮的速度。

缺点：

- 用鼠标从从设备切换主设备时，从设备上的鼠标会停留在屏幕边缘不消失。
- 免费版本不能使用文件拖拽传输和剪切板共享，收费版本价格：
- 远端 insert 键不能使用，这样远端 Windows 上的 Terminal 粘贴快捷键就不能使用了。
