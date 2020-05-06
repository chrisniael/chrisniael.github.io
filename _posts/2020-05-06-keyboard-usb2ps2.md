---
layout: post
title: Arduino 转化 USB 键盘为 PS/2
date: 2020-05-06 12:11:31 +0800
---

<https://github.com/chrisniael/kbd-usb2ps2>

这个项目通过 Arduino 将 USB HID 键盘协议转化为 PS/2 键盘协议 (scan code set 2)，再简单点说就是 USB 母头转 PS/2 公头（仅支持键盘）。

## 由来

公司内网机物理屏蔽了 USB 设备，只能用 PS/2 接口的键盘，尝试买过 USB 转 PS/2 的转接线，但是只有部分自带芯片驱动的键盘才支持转接，很长一段时间都没有找很好的解决方案。无意间看到了 [usb2ps2](https://github.com/limao693/usb2ps2) 这个项目，评估了一下可行性后买了硬件试用了一下，发现这个项目下面这几个很重要的功能都没有实现，基本上还是个不怎么能用的玩具。

* PS/2 键盘初始化

  电脑启动时会与 PS/2 键盘进行消息交互，确定设备的类型、typematic rate、typematic delay、Caps Lock 状态等。

* typematic rate

  键盘按键按下且没有松开时，会产生连续输入，这个值控制连续输入的速度。

* typematic delay

  这个值控制产生连续输入前的延迟时间

[kbd-usb2ps2](https://github.com/chrisniael/kbd-usb2ps2) 实现了这几个必要的功能，并升级了最新的 USB Host Shield 库。

## 原理

{% asset 2020-05-06-keyboard-usb2ps2.png alt=keyboard-usb2ps2 %}

将 USB HID 键盘 Scan Code 转化为 PS/2 Scan Code (set 2)，实现了 PS/2 键盘初始化时与电脑交互协议（让电脑认为 Arduino 是 PS/2 键盘），并模拟了实现了键盘 typematic rate 和 typematic delay 的特点。

## 缺点

* USB Host Shield V2.0 “好像” 不支持自带 Hub 口的键盘，所以如果你的键盘自带 Hub 口，那插在这个系统上是不能正常使用的。用 “好像” 是因为 Arduino 官方 Reference 的 [USBHost](https://www.arduino.cc/en/Reference/USBHost) 明确写了不支持 internal hub 的键盘，在 USB Host Shield 的仓库里提了 [issue](https://github.com/felis/USB_Host_Shield_2.0/issues/518) 验证猜测，但是至今还没有得到回复。

* 还不支持小键盘的使用。
