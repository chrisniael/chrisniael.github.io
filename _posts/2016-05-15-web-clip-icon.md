---
layout: post
title: Safari Web Clip 图标
date: 2016-05-15 12:50:00 +0800
published: false
---

在 IOS 中，你可以将某个网页链接添加到桌面上，方便你快速打开，这个被添加到桌上的链接被成为 Web Clip，类似于 Windows 的桌面快捷方式。和 Windows 的快捷方式一样，Web Clip 的链接是依附在一个图标上的，点击这个图标会启动 Safari 打开链接的网站，Web Clip 使的 Web App 表现的和 Native App 极其相似。

<!--excerpt-->

## 默认 Web Clip 图标

如果网页没有指定 Web Clip 图标，那么 Safari 会使用网页截图的缩放版作为它的图标。

## 自定义 Web Clip 图标

先看一下 Apple 官方推荐的各类 IOS 设备的 Web Clip 图标尺寸

| iPhone 6 Plus | iPhone 6 / iPhone 5 | iPhone 4s | iPad / iPad mini | iPad 2 / iPad mini |
| :-----------: | :-----------------: | :-------: | :--------------: | :----------------: |
| 180 x 180     | 120 x 120           | 120 x 120 | 152 x 152        | 76 x 76            |

下面是两种自定义 Web Clip 图标的方法

* 使用 `apple-touch-icon` 前缀的 `.png` 图标

  在网站根目录下存放下面这几张图片 `apple-touch-icon` 为前缀的图标

  ```shell
  apple-touch-icon.png
  apple-touch-icon-76x76.png
  apple-touch-icon-120x120.png
  apple-touch-icon-152x152.png
  apple-touch-icon-180x180.png
  ```

  后缀 `76x76` 等表示图标的尺寸，请确保图标真实尺寸与文件名中定义的尺寸保持一致。

* `<link>` 标签指定图标

  将下面代码添加到 `<head>` 标签里

  ```html
  <link rel="apple-touch-icon" href="/img/touch-icon-iphone.png">
  <link rel="apple-touch-icon" sizes="76x76" href="/img/touch-icon-ipad.png">
  <link rel="apple-touch-icon" sizes="120x120" href="/img/touch-icon-iphone-retina.png">
  <link rel="apple-touch-icon" sizes="152x152" href="/img/touch-icon-ipad-retina.png">
  <link rel="apple-touch-icon" sizes="180x180" href="/img/touch-icon-iphone-plus-retina.png">
  ```

  `sizes` 属性表示图标的尺寸，如果没有设置 `sizes` 属性，则默认为 `60x60`；`href` 属性表示图标的位置。

Safari 会根据官方推荐的图标尺寸，匹配 `<link>` 标签里定义的图标，如果没有匹配到，则会使用大于推荐尺寸且最小的一个图标，如果没有大于推荐尺寸的图标，则会使用小于推荐尺寸的最大的一个图标。

如果没有使用 `<link>` 指定 Web Clip 图标，Safari 会根据官方推荐的图标尺寸，匹配网站根目录下 `apple-touch-icon` 为前缀的图标，如果没有匹配到，则会使用 `apple-touch-icon.png` 作为默认的 Web Clip 图标。

## 参考链接

* [Configuring Web Applications](https://developer.apple.com/library/iad/documentation/AppleApplications/Reference/SafariWebContent/ConfiguringWebApplications/ConfiguringWebApplications.html#//apple_ref/doc/uid/TP40002051-CH3-SW4), developer.apple.com
* [iOS Human Interface Guidelines](https://developer.apple.com/library/iad/documentation/UserExperience/Conceptual/MobileHIG/IconMatrix.html#//apple_ref/doc/uid/TP40006556-CH27), developer.apple.com
