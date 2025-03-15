#!/bin/bash -eux

apt-get -y install bzip2 g++ make lua5.3 pkg-config lua-posix lua-posix-dev liblua5.3.0 liblua5.3-dev tcl-dev python3-pip nfs-kernel-server
cd ~
git clone https://github.com/TACC/Lmod
cd Lmod
./configure --prefix=/opt/apps
make install

tee -a /home/vagrant/.bashrc << EOF
export PATH=/opt/apps/lmod/lmod/libexec:$PATH
source /opt/apps/lmod/lmod/init/bash
export LMOD_CMD=/opt/apps/lmod/lmod/libexec/lmod
EOF

tee -a /etc/skel/.bashrc << EOF
export PATH=/opt/apps/lmod/lmod/libexec:$PATH
source /opt/apps/lmod/lmod/init/bash
export LMOD_CMD=/opt/apps/lmod/lmod/libexec/lmod
EOF

mkdir -p /modules
chown vagrant:vagrant /modules
cat <<EOF > /etc/exports
/modules    *(fsid=0,ro,sync,no_root_squash,subtree_check,insecure)
EOF

systemctl start nfs-kernel-server.service
exportfs -rav
