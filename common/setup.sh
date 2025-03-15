#!/bin/bash -eux

apt-get -y update && apt-get -y upgrade
apt-get -y install curl unattended-upgrades software-properties-common

# Add vagrant user to sudoers.
echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# Disable daily apt unattended updates, but enable automatic security
# patches and inform reboot monitor

cat <<EOF > /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

cat <<EOF > /etc/apt/apt.conf.d/10periodic
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Verbose 2;
APT::Periodic::RandomSleep 1;
EOF

sed -i 's|//Unattended-Upgrade::Remove-Unused-Dependencies "false"|Unattended-Upgrade::Remove-Unused-Dependencies "true"|' /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's|//Unattended-Upgrade::Automatic-Reboot "false"|Unattended-Upgrade::Automatic-Reboot "false"|' /etc/apt/apt.conf.d/50unattended-upgrades

# Write the reboot reporter

cat <<EOF > /etc/cron.daily/check_reboot_required
#!/usr/bin/env bash
if [ -f /var/run/reboot-required ]; then
  curl "http://monitor.dide.ic.ac.uk/?machine=$hostname.dide.ic.ac.uk&status=1"
else
  curl "http://monitor.dide.ic.ac.uk/?machine=$hostname.dide.ic.ac.uk&status=0"
fi
EOF

chmod 755 /etc/cron.daily/check_reboot_required

# Only allow login with keys

sed -i 's|#PasswordAuthentication yes|PasswordAuthentication no|' /etc/ssh/sshd_config
sed -i 's|#PubkeyAuthentication yes|PubkeyAuthentication yes|' /etc/ssh/sshd_config
if [ -f /etc/ssh/sshd_config.d/50-cloud-init.conf]; then
  sed -i 's|PasswordAuthentication yes|PasswordAuthentication no|' /etc/ssh/sshd_config.d/50-cloud-init.conf
fi

echo 'export PATH="$HOME/.local/bin:$PATH"' > /etc/profile.d/add-local-bin.sh
