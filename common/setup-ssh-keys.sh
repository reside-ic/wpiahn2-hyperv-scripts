#!/usr/bin/env bash
set -ex

if ! which -a curl > /dev/null; then
    echo "installing curl"
    apt-get -y update && apt-get -y upgrade
    apt-get -y install curl
fi

for username in "$@"
do
    curl -sS https://github.com/$username.keys >> "/home/vagrant/.ssh/authorized_keys"
done