---
layout: post
title: 模拟手机 App 发送 HTTP(S) 请求
date: 2020-02-14 22:07:21 +8
---


## HTTP(S) API 安全设计

* 身份认证

    标志用户身份。

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
  * [apktool](https://github.com/iBotPeaches/Apktool) : .apk -> .xml, .smali, .so

      ```bash
      apktool d <file_apk>
      ```

  * unzip: .apk -> .dex
  * [dex2jar](https://github.com/pxb1988/dex2jar) : .dex -> .jar

      ```bash
      d2j-dex2jar classes.dex
      d2j-dex2jar classes2.dex
      ```

  * [jd-gui](https://github.com/java-decompiler/jd-gui) : .jar -> .java

      ```txt
      classes-dex2jar.jar
      classes2-dex2jar.jar
      ```

## 模拟发送 HTTP(s) 请求

* s-, --silent : 不显示进度条和错误信息。
* -c, --cookie-jar &lt;filename&gt; : 指定要保存 cookie 的文件。
* -b, --cookie &lt;data|filename&gt; : 指定要使用的 cookie 值或由 -c, --cookie-jar 保存的 cookie 文件。
* --request : 指定 HTTP 请求使用的方法。
* --url :  指定访问的 URL。
* --data : 指定 POST 方法使用的数据。


```bash
curl --silent \
  --cookie-jar <cookie_file> \
  --request POST \
  --url <url>
  --data <data>
```

```bash
curl --silent \
  --cookie <cookie_file> \
  --cookie-jar <cookie_file> \
  --request POST \
  --url <url>
  --data <data>
```
