#!/bin/bash -eux

apt-get install redis-server -y
sed -i -e 's/supervised no/supervised systemd/g' /etc/redis/redis.conf
sed -i -e 's/protected-mode yes/protected-mode no/g' /etc/redis/redis.conf
sed -i -e 's/bind 127.0.0.1 ::1/# bind 127.0.0.1 ::1/g' /etc/redis/redis.conf
systemctl restart redis
systemctl status redis