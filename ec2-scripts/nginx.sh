#!/bin/bash

# override default server
cp /tmp/nginx/default.conf /etc/nginx/conf.d/default.conf
sed 's/ default_server//;' /etc/nginx/nginx.conf > /etc/nginx/nginx.new
mv /etc/nginx/nginx.new /etc/nginx/nginx.conf

# enable httpd to network connect (SELinux on CentOS)
setsebool -P httpd_can_network_connect true

# restart nginx
service nginx restart         
