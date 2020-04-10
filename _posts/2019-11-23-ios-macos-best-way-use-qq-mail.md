---
layout: post
title: 苹果全家桶使用 QQ 邮箱最佳方式
date: 2019-11-23 23:00:00 +0800
---

QQ 邮箱支持 POP3/SMTP，IMAP/SMTP，Exchange 这三种服务，这三种服务在使用上 Exchange 体验是最好的，其次是 IMAP/SMTP，POP3/SMTP 最差。

<!--excerpt-->

POP3 协议不会把客户端对邮件的操作反馈到邮件服务器上，比如：标记邮件已读、移动邮件，体验自然差。

说 Exchange 协议是最好的，是因为使用 Exchange 协议的客户端获取新邮件的方式不是客户端主动去拉取，而是邮件服务器直接推送过来的，所以 Exchange 协议在获取新邮件的实时性方面最好。但是，macOS 自带的邮件 App 缺不支持手动配置 Exchange 服务器，所以 macOS 不能使用 Exchange 协议收发 QQ 邮箱的邮件。

根据上面分析各个服务的优缺点，推荐两个苹果全家桶使用 QQ 邮箱的方案：

## 方案一

* iOS ：Exchange
* ipadOS ：Exchange
* macOS ：IMAP/SMTP

优点： iOS 和 ipadOS 获取新邮件的速度比 macOS 会快很多。

缺点： 设备间推送消息、红点不能自动同步消除。（例如：我的邮箱收到了一封新邮件，3 个系统都推送了消息在屏幕上，然后我选择使用 macOS 去阅读这封新邮件，阅读完这封邮件后，macOS 上通知栏中关于这封邮件的推送会消失，但是 iOS 和 ipadOS 通知栏对应推送消息就不会因为我已读了这封邮件而同步消失。）

## 方案二

* iOS ：IMAP/SMTP
* ipadOS ：IMAP/SMTP
* macOS ：IMAP/SMTP

优点：设备推送消息、红点可以同步消除（这个对于全家桶体验至关重要）。

缺点：获取新邮件的速度没有 Exchange 协议及时。
