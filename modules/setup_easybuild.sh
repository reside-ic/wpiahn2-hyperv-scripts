#!/bin/bash -eux

export PATH=/opt/apps/lmod/lmod/libexec:$PATH
source /opt/apps/lmod/lmod/init/bash
export LMOD_CMD=/opt/apps/lmod/lmod/libexec/lmod

cd ~
mkdir ebtmp
export EB_TMPDIR=/homes/vagrant/ebtmp
sudo python3 -m pip install --ignore-installed --prefix $EB_TMPDIR easybuild

export PATH=$EB_TMPDIR/local/bin:$PATH
export EB_PYTHON=python3.12
export PYTHONPATH=$EB_TMPDIR/local/lib/$EB_PYTHON/dist-packages/
eb --install-latest-eb-release --prefix /modules/ --skip-sanity-check

mkdir -p $HOME/.config/easybuild
echo '[config]' > $HOME/.config/easybuild/config.cfg
echo 'prefix=/modules' >> $HOME/.config/easybuild/config.cfg
