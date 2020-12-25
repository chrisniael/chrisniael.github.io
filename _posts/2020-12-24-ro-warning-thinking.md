---
layout: post
title: RO 服务器的一个 Warning 引发的思考
date: 2020-12-24 10:37:00 +0800
---

下文可能会让现在的一些同事看了不舒服，但是确实是你们失职了。

```sh
[100%] Linking CXX executable ../../../bin/Debug/GateServer
../../../bin/Debug/libbase.a(loslib.c.o): In function `os_tmpname':
/data/rogame/server-master/base/xlib/lua/loslib.c:60: warning: the use of `tmpnam' is dangerous, better use `mkstemp'
[100%] Built target GateServer
```

编译的时候每个 Target 都输出这个 `warning`，每次编译，一连串这个 `warning`。

RO 具体几号上线的不知道，就当时 git 仓库首次提交算吧，虽然是首次提交，但是其实已经这时已经上线了，代码功能都以成型，且也是存在这个问题的。

```sh
commit d3e535bf40c1604a09e8df9d12fa33bfb4d50989
Author: xxxxxx <xxxxxx@xxxxxxdeMac-mini.local>
Date:   Tue Apr 18 12:22:12 2017 +0800

    submit trunk

commit 56ddd07be4c24d637941761222011f6553502710
Author: xxxxxx <xxxxxx@xindong.com>
Date:   Tue Apr 18 12:14:54 2017 +0800

    Initial commit
```

从 commit 历史记录（submit trunk）推测应该项目之前用的是 svn 来做版本控制。

存留了 3 年多的 `warning` 没人改，最直观能得出的判断是，在 RO 服务器这边 `warning` 可以忽略，但是貌似也不是这个样子的，工作群里也会时不时冒出提醒修改 `warning` 的消息。可能大部分同事的想法是，不是自己写出来 `warning` 不用看，但是作为服务器这边的 leader，是不是失职了呢？

来 XD 5 个月 04 天，RO 虽然在商业上给公司带来了不错的收入，但单纯从技术上看 RO 这款产品，其实是不算成功，看我上一篇写 [RO 服务器优化](./2020-12-12-thinking-about-ro-server-optimization.md)的（其实很想用问题的，给一点面子吧）。压垮我继续在 XD 信念的最后一根根稻草是这个 `warning`（因为解决方案真的是很简单）。从硬件条件看 XD 其实挺好的（办公环境、外设、软件、老板推崇奈飞的理念），但是企业终究还是由人来构成的，从我现有认知看，历史包袱会成为 XD 未来发展的一个阻碍。

已改，“再见” XD。

```sh
commit 680980fa9a5345a7bda36e562ce30d8623cbf44c
Author: shenyu <shenyu@xd.com>
Date:   Mon Dec 21 19:46:01 2020 +0800

    RO-114465 迪士尼活动-引导总览, 去除 lua lib 编译 warning: the use of `tmpnam' is dangerous, better use `mkstemp'
```
