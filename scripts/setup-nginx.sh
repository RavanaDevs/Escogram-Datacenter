#!/bin/bash

apt-get update
apt-get install -y nginx

systemctl start nginx
systemctl enable nginx

HOSTNAME=$(hostname)
echo "Hostname-${HOSTNAME}" > /var/www/html/index.html

systemctl restart nginx
