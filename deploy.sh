#!/bin/bash

set -e

/bin/rm -rf shenyu.me

jekyll build
mv _site shenyu.me
rsync -avzP --delete -e 'ssh -p 8822' shenyu.me root@shenyu.me:/usr/share/nginx/html/
