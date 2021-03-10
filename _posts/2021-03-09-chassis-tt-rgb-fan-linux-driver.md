---
layout: post
title: TT 散热风扇 Linux 驱动
date: 2021-03-09 22:07:00 +0800
---

直接上链接：<https://github.com/chestm007/linux_thermaltake_riing>

下面是我探索的过程记录，用的操作系统是基于 Arch 的 Manjaro，散热的硬件有：

- TT Level 20 GT RGB 机箱自带的 2 个 20cm 的 Riing Plus RGB 风扇和 1 个 14cm 的 Riing Plus RGB 风扇，带 1 个 TT 风扇控制盒（软件版本）
- Floe Riing RGB 360 的 RGB 水泵 和冷排上的 3 个 12cm 的 Riing Plus RGB 风扇，带 1 个 TT 风扇控制盒（软件版本）

硬件的连接方式如下图：

{% asset 2021-03-09-chassis-tt-rgb-fan-linux-driver-device-link-ilustration alt=device-link-illustration %}

这里要注意的是机箱的 3 个散热风扇都没有接在主板的 **CHA_FAN** 接口上，这样 BIOS 里针对 **CHA_FAN** 接口提供的风扇转速调整策略就不能用了。CPU 的散热器还是连接了主板的 **CPU_FAN** 接口了，从 BIOS 里能看到 CPU 的温度和散热风扇的转速情况。

所有风扇都连接了对应的控制器，这里有 2 个控制器，分别控制机箱的风扇和 CPU 的风扇，控制器通过 1 根 Micro USB 线连接至主板的 USB 2.0 接口上（用来通讯）。官方提供了跑在 Windows 上的 [TT RGB Plus](https://ttrgbplus.thermaltake.com/cn/) 来控制控制器上连接的风扇的转速和灯光，Linux 则可以用上面提到的这个开源的驱动。

## 安装 yay

```bash
sudo pacman -S yay
```

## 安装 linux-thermaltake-rgb

```bash
yay -S linux-thermaltake-rgb
```

## 配置 linux-thermaltake-rgb

以 root 身份打开 `/etc/linux_thermaltake_rgb/config.yml`

```yaml
controllers:
  - unit: 1
    type: g3
    devices:
      1: Riing Plus
      2: Riing Plus
      3: Riing Plus
      4: Floe Riing RGB
  - unit: 2
    type: g3
    devices:
      1: Riing Plus
      2: Riing Plus
      3: Riing Plus
fan_manager:
  model: curve
  points:
    - [0, 0] # [temp(*C), speed(0-100%)]
    - [40, 0]
    - [41, 35]
    - [60, 35]
    - [65, 45]
    - [90, 100]
  sensor_name: k10temp
lighting_manager:
  model: full
  r: 0
  g: 0
  b: 0
```

- controllers

  这里要要指定每个控制盒的编号，以及每个控制盒上连接的设置的型号，控制器编号由在控制盒背面的 DIP 开关来设置，开关状态对应的编号如下图：

  {% asset 2021-03-09-chassis-tt-rgb-fan-linux-driver-controller-dip-number alt=controller-dip-number %}

  如果有多个控制盒，确保每个控制盒的编号不会重复。

  然后 `devices` 列表填入每个控制盒（注意区分控制盒编号）上连接的设备型号，这里的序号对应的设备也要和控制盒上接口 ID 连接的设备保持一致。

- fan_manager

  风扇转速控制，有 3 种模式。

  - temp_target

    温度正相关。

  - locked_speed

    固定速度。

  - curve（推荐）

    温度速度相关曲线，相关数值由 `points` 列表指定。

  `sensor_name` 可以通过 `sensors` 命令查看具体名字，以我的设备为例子，执行 `sensors` 命令的输出为：

  ```bash
  k10temp-pci-00db
  Adapter: PCI adapter
  Tctl:         +53.0°C
  Tdie:         +26.0°C

  k10temp-pci-00cb
  Adapter: PCI adapter
  Tctl:         +52.0°C
  Tdie:         +25.0°C

  nvme-pci-0700
  Adapter: PCI adapter
  Composite:    +34.9°C  (low  = -273.1°C, high = +80.8°C)
                         (crit = +80.8°C)
  Sensor 1:     +34.9°C  (low  = -273.1°C, high = +65261.8°C)
  Sensor 2:     +38.9°C  (low  = -273.1°C, high = +65261.8°C)

  enp5s0-pci-0500
  Adapter: PCI adapter
  MAC Temperature:  +42.4°C

  k10temp-pci-00d3
  Adapter: PCI adapter
  Tctl:         +58.9°C
  Tdie:         +31.9°C

  k10temp-pci-00c3
  Adapter: PCI adapter
  Tctl:         +59.4°C
  Tdie:         +32.4°C
  Tccd1:        +52.2°C
  Tccd2:        +52.2°C
  Tccd3:        +52.8°C
  ```

  则 `sensor_name` 为 `k10temp`（去掉后缀 `-pci-****`）。

## 启动 linux-thermaltake-rgb

```bash
sudo systemctl start linux-thermaltake-rgb.service
sudo systemctl enable linux-thermaltake-rgb.service  # 开机自动启动（可选）
```

## 可能会遇到的问题

- 缺少 numpy 模块

  ```bash
  ModuleNotFoundError: No module named 'numpy'
  ```

  ```bash
  sudo pip install numpy
  ```

- 缺少 gobject 模块

  ```bash
  ERROR: pip's dependency resolver does not currently take into account all the packages that are installed. This behaviour is the source of the following dependency conflicts.
  linux-thermaltake-rgb 0.2.0 requires GObject, which is not installed.
  ```

  ```bash
  sudo pip install gobject
  ```

## 缺点

关机后，再按电源键开机，从启动到 Linux 系统加载完成这段时间，风扇会变成没有加载驱动的状态，默认转速运转，RGB 灯光五颜六色，系统启动起来后就恢复成配置的模式工作了，保持开机状态，重启机器，重启过程风扇不会恢复成初始状态工作。
