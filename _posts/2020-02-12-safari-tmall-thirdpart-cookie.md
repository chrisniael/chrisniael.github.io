---
layout: post
title: Safari 访问天猫提示被限制第三方 Cookie
date: 2020-02-12 12:44:00 +0800
---

用 Safari 登陆天猫或者打开天猫的某个商品的链接都会弹出一个提示框，显示下面这段内容：

> 您的浏览器限制了第三方Cookie，这将影响您正常登录，您可以更改浏览器的隐私设置，解除限制后重试。

<!--excerpt-->

根据提示的意思是天猫的页面包含了第三方网站的请求，且这个请求要使用其对应的 Cookie，但是 Safari 限制了不允许这么做。

## 验证原因

`Comman + Alt + I` 打开 Safari 网页检查器，追踪一下打开天猫网页触发了哪些请求，会发现有这样一个请求

```http
GET /member/login.jhtml?... HTTP/1.1
Host: login.taobao.com
```

也就是说 tmall.com 的网站会出发 taobao.com 的请求，这边如果浏览器阻止这个请求携带对应的 Cookie，那么必然会请求失败，结果就会导致 tmall.com 登陆失败。

## 解决方案

Safari → 偏好设置 → 隐私 → 网站追踪 → 阻止跨站 (取消勾选)

## Chrome

Chrome 对这种从第三方网站触发的携带 Cookie 的请求的处理是在 Cookie 里引入了 `SameSite` 属性，这个属性可以是以下三种值之一：

* Strict

    完全禁止从第三方网站触发请求时携带 Cookie，只有当前页面的 URL 与请求目标一致时才会带上 Cookie。

    ```http
    Set-Cookie: CookieName=CookieValue; SameSite=Strict;
    ```

* Lax

    ```http
    Set-Cookie: CookieName=CookieValue; SameSite=Lax;
    ```

    部分情况下允许从第三方网站触发请求时携带 Cookie，见下表：

    | 请求类型  | 示例                                     | 正常情况    | Lax
----|-----------|------------------------------------------|-------------|-------------|
    | 链接      | &lt;a href="..."&gt;&lt;/a&gt;           | 发送 Cookie | 发送 Cookie |
    | 预加载    | &lt;link rel="prerender" href="..."/&gt; | 发送 Cookie | 发送 Cookie |
    | GET 表单  | &lt;form method="GET" action="..."&gt;   | 发送 Cookie | 发送 Cookie |
    | POST 表单 | &lt;form method="POST" action="..."&gt;  | 发送 Cookie | 不发送      |
    | iframe    | &lt;iframe src="..."&gt;&lt;/iframe&gt;  | 发送 Cookie | 不发送      |
    | AJAX      | $.get("...")                             | 发送 Cookie | 不发送      |
    | Image     | &lt;img src="..."&gt;                    | 发送 Cookie | 不发送      |

    当不设置 Cookie 的 `SameSite` 属性的时候，Chrome 默认它的值为 `Lax`，也可以更改 Chrome 这一行为：

    地址栏输入 `chrome://flags/#same-site-by-default-cookies`，更改为 `Disable`，就可以不默认 `SameSite` 为 `Lax`，这样设置 `SameSite` 属性的 Cookie 就可以像上面表格中正常情况那栏那样发送了。

* None

    完全允许从第三方网站触发请求时携带 Cookie，但是设置 Cookie 的 `SameSite` 值为 `None` 必须同时设置 `Secure` 属性，`Secure` 属性的意思是 Cookie 只能通过 https 发送。

    ```http
    Set-Cookie: widget_session=abc123; SameSite=None; Secure
    ```

## 参考链接

* [解决Chrome访问天猫PC端弹出“您的浏览器限制了第三方Cookie...”的问题](https://juejin.im/post/5da13ed8f265da5bbe2a3723), Hal74
* [Cookie 的 SameSite 属性](https://www.ruanyifeng.com/blog/2019/09/cookie-samesite.html), ruanyifeng
