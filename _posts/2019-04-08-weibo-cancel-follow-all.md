---
layout: post
title: 微博批量取消关注
date: 2019-04-08 09:35:00 +8
---

微博本身提供了批量取关的操作，不过没有全选功能，可以利用 Chrome 开发者工具来一键全选

* 使用 PC Chrome 登录微博
* 打开微博的关注列表页，确保当前页面的关注列表都是想要取消关注的，否则会误删
* 打开 Chrome 开发者工具，切换到 console 标签页，在 console 中输入下面代码，回车执行

<!--excerpt-->

  ```js
  $("a[action-type=batselect").click();  // 点击“批量管理”按钮

  // 选中所有条目
  var items = $$('div.markup_choose');
  for (var i=0;i<items.length;i++) {
    items[i].click();
  }

  $("a[action-type=cancel_follow_all]").click()  //点击“取消关注”
  $("a[action-type=ok]").click()  // 点击“确定”
  ```

上面的操作可以删除一页的所有关注，只要重复对剩下页面执行，就可以很快取消关注所有不想关注的人。注意，当操作很频繁的时候，可能会要求输入验证码。

## 参考

* [Double dollar $$() vs Dollar sign $() in Chrome console behavior (stackoverflow.com)](https://stackoverflow.com/questions/35682890/double-dollar-vs-dollar-sign-in-chrome-console-behavior)
