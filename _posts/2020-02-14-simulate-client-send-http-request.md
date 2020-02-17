---
layout: post
title: 模拟手机 App 发送 HTTP(S) 请求
date: 2020-02-14 22:07:21 +8
---


## HTTP(S) API 安全设计

* 身份认证
* 防止数据篡改

    劫持某个请求后，篡改这个请求的某个参数数值，然后再发送。
* 时效性

    劫持某个请求后，再发送同样的请求。

#### 参数签名


#### Cookie


## 破解 HTTP(s) 请求协议


* HTTP(s) 调试代理工具
  * Proxyman (Mac)
* Android 逆向工程工具
  * apktool : .xml, .smali
  * dex2jar : .jar
  * jd-gui : .java


## 模拟发送 HTTP(s) 请求

```bash
curl --silent \
  --cookie-jar <cookie_file> \
  --request POST \
  --url <url>
  --data-raw <data>
```

```bash
curl --silent \
  --cookie <cookie_file> \
  --cookie-jar <cookie_file> \
  --request POST \
  --url <url>
  --data-raw <data>
```
