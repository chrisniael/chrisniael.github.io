---
layout: post
title: Arch Linux 罗技 MX Master 2s 鼠标驱动
date: 2022-12-08 01:03:00 +0800
---

## 安装 logiops

<https://github.com/PixlOne/logiops>

```shell
yay -S logiops-git
```

## 配置

/etc/logid.cfg

```cfg
devices: (
{
    // 鼠标的设备名
    // - Wireless Mouse MX Master
    // - Wireless Mouse MX Master 2S
    // - Wireless Mouse MX Master 3
    name: "Wireless Mouse MX Master 2S";
 
    // SmartShift 开关和灵敏度
    smartshift:
    {
        on: true;
        threshold: 20;
    };
 
    // 灵敏度
    dpi: 800;
  
    buttons: (
        // 手势按钮映射为 Left Meta 键
        {
            cid: 0xc3;
            action =
            {
                type: "Keypress";
                keys: ["KEY_LEFTMETA"];
            };
        }
    );
});
```

## 启动

```shell
sudo systemctl start logid.service
sudo systemctl enable logid.service
```
