---
layout: post
title: brew cask 更新 auto_updates 的 App
date: 2020-04-28 10:16:00 +0800
---

```bash
brew cask upgrade
```

`update` 命令默认并不会更新带 `auto_updates` 标记和版本为 `leatest` 的 App。

```bash
brew cask upgrade --greedy
```

使用 `--greedy` 参数就可以更新包括带 `auto_updates` 标记（如果有新版本的话）和版本为 `leatest` 的 App 了。这样做会更新很多 `leatest` 的 App，但一般情况下，这类 App 我们并不想更新它，我们仅仅想更新有版本升级的（**包括标记为** `auto_updates` **的**）App。

## brew cask 的版本管理逻辑

brew cask 里版本标记就两种类型

* &lt;version&gt; (auto_updates)

  `<version>` 是 App 本身的版本号；
  `auto_updates` 是可选的一个属性，如果存在则表示这个 App 本身会自动更新版本。

* leatest

  `leatest` 字符串的意思是这个 App 并没有版本信息参照。

brew cask 认为并不能可靠的知道带 `auto_updates` 标记和版本为 `leatest` 的 App是否有版本更新，所以 `update` 命令默认不更新这两类 App。

## 自定义命令

```bash
brew cask outdated --greedy
```

`outdated` 命令可以查看所有有版本更新的 App，`--greedy` 参数的用法与  `update` 一致。

```bash
function brew-cask-upgrade() {
  # 去除末尾的空格
  local cask_list=$(eval echo $(brew cask outdated --greedy --verbose | grep -v '!= latest' | awk -F ' ' '{print $1}' | tr '\n' ' '))
  # 不用 eval 会导致多个 token 的时候不被当成多参数
  eval brew cask upgrade $cask_list
}
```

将这个自定义函数 `brew-cask-upgrade` 添加到 `~/.zshrc` 里，然后每次打算更新 App 的时候，直接执行  `brew-cask-upgrade` 就能将所有有版本更新的 App 更新好（**包括标记为** `auto_updates` **的**）。
