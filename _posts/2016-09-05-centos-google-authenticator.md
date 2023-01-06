---
layout: post
title: CentOS 使用 Google Authenticator 登录验证
date: 2016-09-05 08:45:00 +0800
---

[Google Authentication 项目](https://github.com/google/google-authenticator) 包含了多个手机平台的一次性验证码生成器的实现，以及一个可插拔的验证认证模块（PAM）。这些实现支持基于 HMAC 的一次性验证码（HOTP）算法（[RFC 4226](https://tools.ietf.org/html/rfc4226)）和基于时间的一次性验证码（TOTP）算法（[RFC 6238](https://tools.ietf.org/html/rfc6238)）。

<!--excerpt-->

下面将在 CentOS 上安装并使用 [Google Authenticator](https://github.com/google/google-authenticator) 做登录的身份验证，当前系统的版本为

```shell
CentOS Linux release 7.2.1511 (Core)
```

## 安装 Google Authenticator PAM module

* 确保 `ntpd` 已安装并正常运行运行

  ```shell
  yum install -y ntpdate
  systemctl start ntpd
  systemctl enable ntpd
  ```

  `ntpdate` 是用来自动同步时间的程序，这里启动它并设置它开机自动启动。

* 安装一些接下去会用到的组件

  ```shell
  yum install -y git make gcc libtool pam-devel
  ```

* 编译安装 [Google Authenticator PAM module](https://github.com/google/google-authenticator/tree/master/libpam)

  ```shell
  git clone https://github.com/google/google-authenticator
  cd google-authenticator/libpam
  ./bootstrap.sh
  ./configure
  make
  make install
  ln -s /usr/local/lib/security/pam_google_authenticator.so /usr/lib64/security/
  ```

## 配置 SSH 服务

打开 `/etc/ssh/sshd_config` 文件

```shell
vim /etc/ssh/sshd_config
```

修改下面字段的配置

```text
ChallengeResponseAuthentication yes
PasswordAuthentication no
PubkeyAuthentication yes
UsePAM yes
```

然后重启一下 `sshd` 服务，使配置生效

```shell
systemctl restart sshd
```

这里将 `PubkeyAuthentication` 配置成了 `yes` 表示支持公钥验证登录，即使某个账号启用了 Google Authenticator 验证，只要登录者机器的公钥在这个账号的授权下，就可以不输入密码和 Google Authenticator 的认证码直接登录。

## 配置 PAM

打开 `/etc/pam.d/sshd` 文件

```shell
vim /etc/pam.d/sshd
```

这里分四种情况来配置

* 验证密码和认证码，没有启用 Google Authenticator 服务的账号只验证密码（推荐）

  ```text
  auth substack password-auth
  #...
  auth required pam_google_authenticator.so nullok
  ```

  `password-auth` 与 `pam_google_authenticator` 的先后顺序决定了先输入密码还是先输入认证码。

* 验证密码和认证码，没有启用 Google Authenticator 服务的账号无法使用密码登录

  ```text
  auth substack password-auth
  #...
  auth required pam_google_authenticator.so
  ```

* 只验证认证码，不验证密码，没有启用 Google Authenticator 服务的账号不用输入密码直接可以成功登录

  ```text
  #auth substack password-auth
  #...
  auth required pam_google_authenticator.so nullok
  ```

  注释掉 `auth substack password-auth`  配置就不会再验证账号密码了。

* 只验证认证码，不验证密码，没有启用 Google Authenticator 服务的账号无法使用密码登录

  ```text
  #auth substack password-auth
  #...
  auth required pam_google_authenticator.so
  ```

## 启用 Google Authenticator

切换至想要使用 `Google Authenticator` 来做登录验证的账号，执行下面操作

```shell
google-authenticator
```

然后会出现下面一系列交互式的对话做对应的设置

```text
Do you want authentication tokens to be time-based (y/n) y
https://www.google.com/chart?chs=200x200&chld=M|0&cht=qr&chl=otpauth://totp/shenyu@shenyu.me%3Fsecret%3DKHMH46EWI2RIRZ53KQTNGHXNP4%26issuer%3Dshenyu.me
# 这里是个二维码
Your new secret key is: KHMH46EWI2RIRZ53KQTNGHXNP4
Your verification code is 753579
Your emergency scratch codes are:
  99181037
  68865807
  88385439
  59103432
  81045035
```

这里会显示一个二维码，如果你的终端终端不支持显示二维码，可以手动打开这个网页链接（墙）来查看二维码或者手动输入后面的密钥（secret key）来代替扫描二维码，之后的操作会用到这个二维码/密钥（secret key）。这里还有一个认证码（verifiction code），暂时不知道有什么用，以及 5 个紧急救助码（emergency scratch code），紧急救助码就是当你无法获取认证码时（比如手机丢了），可以当做认证码来用，每用一个少一个，但其实可以手动添加的，建议如果 root 账户使用 Google Authenticator 的话一定要把紧急救助码另外保存一份。

```text
Do you want me to update your "/home/test/.google_authenticator" file? (y/n) y
```

是否更新用户的 Google Authenticator 配置文件，选择 `y` 才能使上面操作对当前用户生效，其实就是在对应用户的 `Home` 目录下生成了一个 `.google_authenticator` 文件，如果你想停用这个用户的 Google Authenticator 验证，只需要删除这个用户 `Home` 目录下的 `.google_authenticator` 文件就可以了。

```text
Do you want to disallow multiple uses of the same authentication
token? This restricts you to one login about every 30s, but it increases
your chances to notice or even prevent man-in-the-middle attacks (y/n) y
```

每次生成的认证码是否同时只允许一个人使用？这里选择 `y`。

```text
By default, tokens are good for 30 seconds. In order to compensate for
possible time-skew between the client and the server, we allow an extra
token before and after the current time. If you experience problems with
poor time synchronization, you can increase the window from its default
size of +-1min (window size of 3) to about +-4min (window size of
17 acceptable tokens).
Do you want to do so? (y/n) n
```

是否增加时间误差？这里选择 `n`。

```text
If the computer that you are logging into isn't hardened against brute-force
login attempts, you can enable rate-limiting for the authentication module.
By default, this limits attackers to no more than 3 login attempts every 30s.
Do you want to enable rate-limiting (y/n) y
```

是否启用次数限制？这里选择 `y`，默认每 30 秒最多尝试登录 3 次。

上面交互式的设置也可用通过参数一次性设置（推荐）

```shell
google-authenticator -t -f -d -l shenyu@shenyu.me -i SHENYU.ME -r 3 -R 30 -W
```

可以看到，通过参数还可以自定义 `发行商` 和 `标签`，执行 `google-authenticator -h` 来查看所有的参数设置

```shell
google-authenticator [<options>]
 -h, --help               Print this message
 -c, --counter-based      Set up counter-based (HOTP) verification
 -t, --time-based         Set up time-based (TOTP) verification
 -d, --disallow-reuse     Disallow reuse of previously used TOTP tokens
 -D, --allow-reuse        Allow reuse of previously used TOTP tokens
 -f, --force              Write file without first confirming with user
 -l, --label=<label>      Override the default label in "otpauth://" URL
 -i, --issuer=<issuer>    Override the default issuer in "otpauth://" URL
 -q, --quiet              Quiet mode
 -Q, --qr-mode={NONE,ANSI,UTF8}
 -r, --rate-limit=N       Limit logins to N per every M seconds
 -R, --rate-time=M        Limit logins to N per every M seconds
 -u, --no-rate-limit      Disable rate-limiting
 -s, --secret=<file>      Specify a non-standard file location
 -S, --step-size=S        Set interval between token refreshes
 -w, --window-size=W      Set window of concurrently valid codes
 -W, --minimal-window     Disable window of concurrently valid codes
```

## 设置 Google Authenticator 手机 App

在手机上下载并安装 Google Authenticator

| 手机类型 | App 程序名称                                                                                  |
| :------: | :-------------------------------------------------------------------------------------------: |
| IOS      | [Google Authenticator](https://itunes.apple.com/cn/app/google-authenticator/id388497605?mt=8) |
| Android  | 谷歌动态口令（请在手机对应的应用商店里搜索下载）                                              |

安装完后，打开 Google Authenticator/谷歌动态口令 App，点击 `开始设置`，选择 `扫描条形码` 扫描上面 `google-authenticator` 命令生成的二维码，然后手机上就能看到对应的认证码了。

![](/assets/2016-09-03-centos-google-authenticator-app.png)

这里的认证码每 30 秒变化一次，认证码上面的 `SHENYU.ME` 对应的是 `google-authenticator` 参数 `-i` 设置的发行商，认证码下面的 `shenyu@shenyu.me` 对应的是 `google-authenticator` 参数 `-l` 设置的标签，如果你没有通过 `google-authenticator` 的参数设置发行商和标签，默认会使用系统的 `hostname` 来作为发行商，标签则则使用用户名和 `hostname` 的组合，格式为 `username@hostname`，标签其实是后期可以通过手机App来修改的，而发行商则修改不了。

现在重新使用 SSH 登录服务器，就会要求输入密码和 `Verification code` 来验证身份。如果登陆时遇到问题，请查看日志文件 `/var/log/secure`。

## 参考链接

* [Google Authenticator](https://github.com/google/google-authenticator), github.com
* [Playing with two-factor authentication in Linux using Google Authenticator](https://blog.remibergsma.com/2013/06/08/playing-with-two-facor-authentication-in-linux-using-google-authenticator/), Remi Bergsma
* [Two-Step Authentication For SSH On Centos 6 Using Google Authenticator](http://blog.nowherelan.com/2014/01/04/two-step-authentication-for-ssh-on-centos-6-using-google-authenticator/), David Lehman
