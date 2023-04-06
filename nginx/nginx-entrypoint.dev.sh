#!/bin/sh
set -euox pipefail
#replace k8s host with docker-compose
sed -i 's/127\.0\.0\.1/laravel/' /etc/nginx/include/upstream.cfg
#local no https
sed -i 's/fastcgi_param\s*https\s*on/fastcgi_param\ HTTPS\ off/ig' /etc/nginx/include/php.cfg
#sed -i 's/https/http/g' /etc/nginx/include/redirect.cfg
nginx -g 'daemon off;'