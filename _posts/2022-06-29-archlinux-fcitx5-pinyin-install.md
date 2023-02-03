---
layout: post
title: Arch Linux 安装 Fcitx 5 拼音输入法
date: 2022-06-29 00:14:00 +0800
---

Arch Linux，GNOME (X11) 桌面系统。

## 安装

```bash
su -
pacman -S fcitx5-im
pacman -S fcitx5-chinese-addons 
```

## 安装 Kimpannel 扩展

想要在操作系统托盘栏显示 fcitx 5 输入法状态，就需要安装 Gnome 的 kimpannel 扩展，在 Gnome 的扩展商店里它叫做 [Input Method Pannel](https://extensions.gnome.org/extension/261/kimpanel/)。

打开扩展的链接，把页面上方的按钮按成 ON，然后会弹出安装的提示窗，点击安装。

用 GNOME 自带的浏览器 Epiphany 可以直接安装 [extensions.gnome.org](extensions.gnome.org) 里的扩展。如果是 Chrome 则需先安装 [chrome-gnome-shell](https://aur.archlinux.org/packages/chrome-gnome-shell/) ，并安装 Chrome 插件 [GNOME Shell integration](https://chrome.google.com/webstore/detail/gnome-shell-integration/gphhapmejobijbbhgpjhcjognlahblep)

## 配置

### 环境变量

/etc/environment

```bash
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
INPUT_METHOD=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=ibus
```

配置完后重启生效。

### Fcitx 5 配置

- 增加拼音输入法

  Fcitx 5 配置 - 输入法

  取消勾选 **仅显示当前语言(S)**，在右侧可用输入法列表里找到 **拼音**，双击，将 **拼音** 移动到左侧当前输入法列表。

- 配置输入法切换快捷键

  Fcitx 5 默认切换输入法的快捷键为 **Ctrl+空格**，这个快捷键被 JetBrain 开发工具用作补全用，将其改为 **Super+空格**。

  Fcitx 5 配置 - 全局选项 - 切换启用/禁用输入法

- 取消系统默认切换输入法快捷键

  这里还得将 GNOME 默认输入法引擎 IBus 的快捷键取消，Arch 上默认的输入法引擎 IBus 的切换输入法的快捷键默认就是 **Super + Space**，冲突了。
  
  设置 - 键盘 - 键盘快捷键 - 查看及自定义快捷键 - 打字
  
  将 **切换至上一个输入源** 和 **切换至下一个输入源** 的快捷键都删除，按 **删除** 禁用快捷键。

- 禁用或修改一些 Fcitx 5 默认的快捷键

  Fcitx 5 默认的一些快捷键可以考虑禁用，容易与其他一些应用程序冲突，且不常用，包括：

  全局选项 - 快捷键

  - 临时在当前和第一个输入法之间切换：左Shift
  - 向前切换输入法：Contrl+左Shift
  - 向后切换输入法：Contrl+右Shift
  - 向前切换输入法分组：Super+空格
  - 向后切换输入法分组：Super+空格
  - 切换是否使用嵌入预编辑

  附加组件 - 模块

  - 标点：Ctrl+.
  - 剪切板：Ctrl+; 
  - 简繁转化：Ctrl+Shift+F
  - 快速输入：Super+`/Super+;
  - 云拼音：Control+Alt+Shift+C
  - Unicode：Control+Alt+Shift+V

## 常见问题

- PuTTY 终端内无法使用 fcitx

  编辑 /usr/share/applications/putty.desktop

  ```text
  Exec=env GTK_IM_MODULE=xim putty %u
  ```

  重新打开 putty 生效。

## 参考

- <https://wiki.archlinux.org/title/Fcitx5_(简体中文)>
- <https://wiki.archlinux.org/title/GNOME_(简体中文)>
- <https://askubuntu.com/a/144971>
