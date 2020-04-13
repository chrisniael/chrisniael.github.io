---
layout: post
title: CentOS 部署 Git 服务器
date: 2017-01-03 21:29:31 +0800
---

GitHub 确实好用，不过非付费用户托管在上面的项目只能是 public 的，想要托管私有项目的话，每个月要花费 7 美元（数量没有限制），一年下来还算一笔比较多的支出，所以如果你有私有项目需要托管的话，完全可以考虑自己部署一个 Git 服务器来使用，而且如果在国内有自己的服务器的话，使用速度方面会比 GitHub 要好。

<!--excerpt-->

## Init 远程仓库

Git 服务器简单来说就是一台托管很多 Git 远程仓库的服务器。这里先建立一个远程仓库。

* 新建一个用户 git

  ```shell
  useradd \
      -r \
      -s /bin/sh \
      -c 'git version control' \
      -d /home/git \
      git
  mkdir -p /home/git
  chown git:git /home/git
  ```

* 切换至 git 用户，并初始化一个裸仓库 overwatch.git

  ```shell
  sudo -iu git
  git init --bare overwatch.git
  ```

这样，一个简易远程仓库就建立好了。

## Clone 远程仓库

Git 支持的数据传输协议有下面这些

* 本地传输
* SSH 协议（最常见）
* Git 协议
* HTTP/HTTPS 协议（速度最慢）

本地传输、SSH 协议与 Git 协议在传输数据时都会尽可能对数据压缩，所以相对于 HTTP/HTTPS 协议这三个协议在传输文件时会快好多。下面配置 Git 服务器，使得它支持 SSH 与 Git 协议（本地传输与 HTTP/HTTPS 协议这里暂不做讲解），并通过这两种协议 Clone 上面建立的远程仓库。

### SSH 协议

* 切换一台机器，生成当前用户的 SSH 密钥（已经存在请略过这步）

   ```shell
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```

   请将 `your_email@example.com` 替换你自己的邮箱地址。

* 将生成的公钥添加到 Git 服务器（shenyu.me）

  ```shell
  ssh-copy-id -i ~/.ssh/id_rsa.pub git@shenyu.me
  ```

  `~/.ssh/id_rsa.pub` 是上一步生成的公钥文件的路径。这里也可以手动将公钥内容追加到到 Git 服务器 `/home/git/.ssh/authorized_keys` 里（使用用户 git ）。 这里生成并上传公钥到 Git 服务器，是为了每次 Pull（Clone）和 Push 的时候，免去输入用户 git 的登陆密码的麻烦。

* 使用 SSH 协议 Clone 刚刚建立的仓库

  ```shell
  git clone shenyu@shenyu.me:overwatch.git
  ```

  `shenyu.me` 是绑定到 Git 服务器上的域名，可以替换成 IP 地址。仓库的地址还可以使用 `ssh://` 前缀来显示表明使用的协议，所以下面这两种仓库地址的写法都是可以的

  * shenyu@shenyu.me:overwatch.git
  * ssh://shenyu@shenyu.me/overwatch.git

### Git 协议

为了使 Git 服务器支持 Git 协议，需要在 Git 服务器上安装 git-daemon。git-daemon 是 Git 自带的一项功能，它能够让所有人都能拥有读取仓库的权限。

* 安装 git-daemon

  ```shell
  yum install git-daemon -y
  ```

* 修改 git-daemon 的 systemd 配置文件 `/usr/lib/systemd/system/git@.service`

  ```shell
  vim /usr/lib/systemd/system/git@.service
  ```

  内容如下

  ```text
  [Unit]
  Description=Git Repositories Server Daemon
  Documentation=man:git-daemon(1)

  [Service]
  User=git
  ExecStart=-/usr/libexec/git-core/git-daemon --base-path=/home/git/repositories
  --syslog --inetd --verbose
  StandardInput=socket
  ```

  git-daemon 配置文件路径，可以通过 `rpm -ql git-daemon` 来查看，这个方法同样适用于其他通过 yum 来安装的程序。

* 启动 git-daemon

  ```shell
  systemctl start git.socket
  ```

* 如果启用了防火墙，则需要开放 `9418` 端口

  * 新建配置文件 `/etc/firewalld/services/git-daemon.xml`

    ```shell
    vim /etc/firewalld/services/git-daemon.xml
    ```

    内容如下

    ```xml
    <?xml version="1.0" encoding="utf-8"?>
    <service>
      <short>git-daemon (git)</short>
      <description>Git is the protocol used to git version control. If you plan to make your git reponsitory cone via git protocol, enable this option..</description>
      <port protocol="tcp" port="9418"/>
    </service>
    ```

  * 添加 git-daemon 服务

    ```shell
    firewall-cmd --reload
    firewall-cmd --get-services | grep "git-daemon"
    firewall-cmd --permanent --add-service=git-daemon
    firewall-cmd --reload
    ```

* 使用 Git 协议 Clone 刚刚建立的仓库

  ```shell
  git clone git://shenyu.me/overwatch.git
  ```

上面配置的支持 SSH 协议与 Git 协议的 Git 服务器可以满足基本的私有仓库的需求，但是如果要实际用到团队协作开发中去的话，这种方式的缺点就显而易见了。比如，每次新建一个远程仓库和添加开发成员都需要登陆 Git 服务器来操作，这样管理很多项目和开发成员的话就会很麻烦。相对于这种简易的 Git 服务器，Gitosis 与 Gitolite 更适合团队协作开发使用，下面使用 Gitosis 来配置 Git 服务器。

## Gitosis

* 安装 Gitosis

  ```shell
  git clone git://github.com/res0nat0r/gitosis.git
  cd gitosis
  python setup.py install
  ```

* 新建一个 git 用户（和上面的一样，做过的话，就不要再做了）

  ```shell
  useradd \
      -r \
      -s /bin/sh \
      -c 'git version control' \
      -d /home/git \
      git
  mkdir -p /home/git
  chown git:git /home/git
  ```

* 将你本地电脑的公钥上传至 Git 服务器上，没有公钥的话生成一下

  ```shell
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   scp .ssh/id_rsa.pub root@shenyu.me/tmp/
  ```

   请将 `your_email@example.com` 替换你自己的邮箱地址。

* 切换至 git 用户，初始化 Gitosis

  ```shell
  sudo -iu git
  gitosis-init < /tmp/id_rsa.pub
  exit
  ```

  `/tmp/id_rsa.pub` 是上一步上传到 Git 服务器上的本地电脑的公钥。

* 在本地电脑上 Clone gitosis-admin 仓库

  ```shell
  git clone git@shenyu.me:gitosis-admin.git
  ```

  这个仓库就是用来管理 Git 服务器上的仓库和用户的，所以，想要添加删除 Git 服务器上的用户和仓库，只要修改这个仓库的内容然后上传就行了，相当方便。

* 添加一个仓库和用户

  * 将用户的公钥文件拷贝到 `keydir` 目录下

    ```bash
    cp id_rsa.pub gitosis-admin/keydir/shenyu@local.pub
    ```

    本质上来说，Gitosis 是用来方便管理用户公钥的。

  * 编辑 gitosis-admin配置文件 `gitosis.conf`

    ```shell
    vim /gitosis-admin/gitosis.conf
    ```

    内容如下

    ```text
    [gitosis]
    gitweb = no
    daemon = no

    [group gitosis-admin]
    members = shenyu@shenyu.me
    writable = gitosis-admin

    [group developer]
    members = shenyu@ztgame.com shenyu@shenyu.me
    writable = overwatch

    [repo overwatch]
    owner = 沈煜 <shenyu@ztgame.com>
    description = Hero never die.
    gitweb = yes
    daemon = yes
    ```

    * `gitweb` ：指定仓库是否显示在 gitweb 页面上（后面会配置 gitweb），可以在 `gitosis` 后配置让所有仓库都显示在 gitweb 中，也可以在 `repo` 后配置显示某个仓库（先将全局显示关闭）。
    * `daemon` ：指定仓库是否支持 git 协议的（需要启动了 git-daemon 服务，上面配置过了），用法和 `gitweb` 一样
    * `group` ：定义一个包含若干成员的组
    * `members`：定义组成员（成员的名字与成员的公钥文件名一致，不包括后缀名 `.pub`），成员之间用空格分隔
    * `writable`：定义组可以读写的仓库，仓库之间用空格分隔
    * `repo` ：定义一个仓库
    * `owner` ：仓库拥有者的信息
    * `description` ：仓库的描述

    更详细的配置示例说明，请参考 gitosis 仓库下 [example.conf](https://github.com/res0nat0r/gitosis/blob/master/example.conf) 文件。

  * 提交上传

    ```shell
    cd gitosis-admin
    git add -A
    git commit -m "Add repo overwatch and user shenyu@ztgame.com"
    git push origin master
    ```

* Clone 仓库

  Gitosis 添加的新仓库不能直接 Clone，需要本地初始化一下并 Push 一下

  ```shell
  git init
  git remote add origin git@shenyu.me:overwatch.git
  touch README.md
  git add -A
  git commit -m "Init."
  git push origin master:master
  ```

  然后其他用户就可以通过 SSH 协议或者 Git 协议（只读）来 Clone 仓库了。

## Gitweb

GitWeb 是 Git 自带一个 CGI 脚本，它提供了一个浏览 Git 仓库信息的 Web 界面（简化版的 GitHub）

* 安装 fcgi-devel，fcgiwrap 和 fcgiwrap

  ```shell
  yum install fcgi-devel spawn-fcgi
  cd /usr/local/src/
  git clone git://github.com/gnosek/fcgiwrap.git
  cd fcgiwrap
  autoreconf -i
  ./configure
  make
  make install
  ```

* 配置 fcgiwrap 的 systemd 配置

  ```shell
  vim /usr/lib/systemd/system/fcgiwrap.service
  ```

  内容如下

  ```text
  [Unit]
  Description=Simple server for running CGI applications over FastCGI
  After=syslog.target network.target

  [Service]
  Type=forking
  Restart=on-abort
  PIDFile=/var/run/fcgiwrap.pid
  ExecStart=/usr/bin/spawn-fcgi -s /var/run/fcgiwrap.sock -P /var/run/fcgiwrap.pid -u nginx -g nginx -- /usr/local/sbin/fcgiwrap
  ExecStop=/usr/bin/kill -15 $MAINPID

  [Install]
  WantedBy=multi-user.target
  ```

* 启动 fcgiwrap ，并设置它开机自动启动

  ```shell
  systemctl enable nginx fcgiwrap
  systemctl start nginx fcgiwrap
  ```

* 配置 Nginx

  * 添加配置文件 `/etc/nginx/conf.d/git.shenyu.conf`

    ```shell
    vim /etc/nginx/conf.d/git.shenyu.me.conf
    ```

    内容如下

    ```nginx
    server
    {
        listen      80;
        server_name git.shenyu.me;
        index       gitweb.cgi;
        root        /var/www/git;
        location /gitweb.cgi {
            include       fastcgi_params;
            gzip          off;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_pass  unix:/var/run/fcgiwrap.sock;
        }
    }
    ```

    这里绑定了域名 `git.shenyu.me`（请替换成你自己的） 和 `80` 端口。

  * 加载 Nginx 配置

    ```shell
    nginx -s reload
    ```

  * 在域名的提供商那边设置 A 记录解析到 Git 服务器的 IP 地址上。

  * 将用户 nginx 加入 git 组

    ```shell
    usermod -a -G git nginx
    systemctl restart fcgiwrap
    ```

    这步操作的目的，是为了让 Nginx 能有权限读取仓库的内容（Nginx 默认的启动用户是 nginx），而且一定要重启一下 fcgiwrap ，否则无法立刻生效

  * 配置 gitweb

    * 编辑配置文件 `/etc/gitweb.conf`

      ```shell
      vim /etc/gitweb.conf
      ```

      内容如下

      ```text
      our $projects_list = "/home/git/gitosis/projects.list";
      our $projectroot = "/home/git/repositories";
      our @git_base_url_list = qw(git://shenyu.me ssh://git@shenyu.me);
      ```

      * \$projects_list ：指定仓库清单的文件，这个文件里列出的所有仓库都会显示在 gitweb 中（存在的话），配合 gitosis 使用的话，gitosis 会自动维护仓库清单文件 `projects.list`
      * \$projectroot ：指定仓库存放的根目录
      * @git_base_url_list ：指定显示在 gitweb 仓库详情里的 URL 前缀

  * 访问 GitWeb

    使用浏览器打开上面 Nginx 配置的域名，这里使用的是 [http://git.shenyu.me](http://git.shenyu.me)。

## htpasswd

htpasswd 可以用来给网站做简单的加密访问功能，这里将它用在 GitWeb 上。

* 生成密码文件

  ```bash
  htpasswd bc /var/www/git/.htpasswd shenyu 123456
  ```

  htpasswd 命令最后两个参数是账号和密码。

* 配置 Nginx

  ```config
  server
  {
      listen      80;
      server_name git.shenyu.me;
      index       gitweb.cgi;
      root        /usr/share/nginx/html/git.shenyu.me;
      location /gitweb.cgi {
          include       fastcgi_params;
          gzip          off;
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
          fastcgi_pass  unix:/var/run/fcgiwrap.sock;
          auth_basic "gitweb-auth";
          auth_basic_user_file /usr/share/nginx/html/git.shenyu.me/.htpasswd;
      }
  }
  ```

* 热更 Nginx 配置

  ```bash
  nginx -s reload
  ```

现在访问 <http://git.shenyu.me> 就需要输入账号和密码了。

## 参考链接

* [Gitosis](https://github.com/res0nat0r/gitosis), github.com
* [Gitweb](https://wiki.archlinux.org/index.php/Gitweb), wiki.archlinux.org
* [htpasswd 官网](https://httpd.apache.org/docs/2.4/programs/htpasswd.html)
