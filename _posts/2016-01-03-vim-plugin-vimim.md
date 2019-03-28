---
layout: post
title: Mac 配置 VimIM
date: 2016-01-03 18:30:00 +8
---

在 Vim 中使用系统的中文输入法来输入中文，从输入模式切换到命令模式或普通模式，都需要先把中文输入法切换到英文才行，这样频繁切换输入法的操作着实让人感觉很麻烦，VimIM 这个插件就能让你在 Vim 中输入中文时不用切换输入法就能直接使用命令模式或普通模式。

<!--excerpt-->

VimIm 的本地词库依赖于 [Berkeley DB](http://www.oracle.com/technetwork/database/database-technologies/berkeleydb/downloads/index.html) 和 Berkeley DB For Python 的组件，Mac OS X 默认安装的 Berkeley DB 本并不能兼容 VimIM 插件，所以这里需要重新安装 Berkeley DB 6.1.26。

可以使用 `db_archive -V` 命令查看 Berkeley DB 版本。

## 安装 Berkeley DB 6.1.26

切换到 root 账号，下载 Berkeley DB 6.1.26 的源码，编译并安装。不能使用 Homebrew 来安装 Berkeley DB，因为 Homebrew 安装的 Berkeley DB 的版本太新，也不能兼容对应的 Python 组件，但是可以用 Homebrew 来管理手动安装的软件，只要目录结构安装 Homebrew 的管理方式来建立就好了

```shell
sudo su -
wget http://download.oracle.com/berkeley-db/db-6.1.26.tar.gz
tar xvf db-6.1.26.tar.gz
cd db-6.1.26/build_unix
mkdir -p /usr/local/Cellar/berkeley-db/6.1.26
../dist/configure --prefix=/usr/local/Cellar/berkeley-db/6.1.26
make
make install
```

成功安装后， Berkeley DB 就可以像正常使用 Homebrew 安装的软件一样来被 Homebrew 操作了，包括建立软链接，删除软件等。

使用 Homebrew 来生成 Berkeley DB 可执行文件的软链接，默认软链接在 `/usr/local/bin`，所以确保环境变量 `PATH` 包含已包含这个目录

```shell
brew link berkeley-db
```


## 安装 Berkeley Db For Python 组件

安装 Berkeley Db 的 Python 组件需要使用 [pip](https://en.wikipedia.org/wiki/Pip_(package_manager))，Mac OS X 默认没有安装 pip，切换到 root 账号，使用 [easy_install](http://peak.telecommunity.com/DevCenter/EasyInstall) 安装 pip

```shell
easy_install pip
```

然后使用 pip 来安装 dsddb3

```shell
YES_I_HAVE_THE_RIGHT_TO_USE_THIS_BERKELEY_DB_VERSION=1 BERKELEYDB_DIR=/usr/local/Cellar/berkeley-db/6.1.26 pip install bsddb3
```

## 安装 VimIM

这里使用 [Vundle](https://github.com/VundleVim/Vundle.vim) 来安装 VimIm 插件，也可以手动下载安装 VimIm，但是不推荐这样做。在 Vim 配置文件 `~/.vimrc` 中添加下面内容

```vim
Plugin 'VimIM'
```

然后在命令行执行

```shell
vim +BundleInstall +qa!
```

## 配置 VimIM 词库

下载词库至 `~/.vim/bundle/VimIM/plugin/` 目录中

* [海量词库](https://raw.githubusercontent.com/vimim/vimim/master/plugin/vimim.gbk.bsddb)
* [英文词库](https://raw.githubusercontent.com/vimim/vimim/master/plugin/vimim.txt)（不推荐使用）

VimIM 默认是开启云词库的，要使用本地词库，必须先关闭云词库，在 Vim 配置 `~/.vimrc` 中添加下面内容

```vim
let g:Vimim_cloud=-1
```

VimIM 其实能支持搜狗、百度、QQ、谷歌的云词库，匹配起来还是相当快的。但使用的时候，如果网络不稳定，Vim 就直接卡死，所以并不推荐使用云词库，如果你想使用云词库，可以这样配置

```vim
let g:Vimim_cloud = 'sogou,baidu,qq,google'
```

## 使用 VimIM

* 有弹窗输入中文

  打开 Vim ，按 `i` 进入插入模式，按 `Ctrl` + `/` 切换至中文输入法，然后输入拼音就会有候选词弹窗，输入候选词前面的序号来选中候选词，如果候选词不在第一页，可以通过 `Ctrl` + `n` 和 `Ctrl` + `p` 来上下翻页，然后按 `空格` 来选择候选词，想要关闭 VimIM 输入法，请再按 `Ctrl` + `/` 。

* 无弹窗输入中文

  打开 Vim ，按 `g` 和 `i` 进入插入模式并切换至 VimIM 中文输入法，然后输入拼音，按 `空格` 来变换输入的拼音为中文，如果变换后的中文不是你想输入的，可以使用 `Ctrl` + `n` 和 `Ctrl` + `p` 来前后切换候选词，按空格来确定候选词并变换之后的拼音，整个过程是没有候选词弹窗的，想要关闭 VimIM 输入法，请按 `Ctrl` + `/` 。

  这种方式的缺点就是匹配的候选词的时候不知道要切换多少次，所以并不推荐这种方式。

* 拼音搜索中文

  用 Vim 打开一个文本，输入 `/ceshi` 来搜索关键字，然后回车，此时会提示 `Pattern not found`（确保文中没有 `ceshi` 这个 5 个字母的关键字，有的话则匹配不到中文的），然后继续按 `n` ，如果这个文本里有 `测试` 或拼音一样的中文的话，则都会被搜索匹配到，继续按 `n` 来匹配一下一个关键字。

  这个功能的缺点就是当上下文中存在搜索拼音的本身时，就会搜索不到拼音对应的中文。


## 参考资料

* [Berkeley DB (wikipedia.org)](https://zh.wikipedia.org/wiki/Berkeley_DB)
* [VimIM (wikipedia.org)](https://zh.wikipedia.org/wiki/VimIM)
