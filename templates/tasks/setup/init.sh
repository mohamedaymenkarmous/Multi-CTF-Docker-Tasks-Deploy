#!/bin/bash
apt-get update
apt-get upgrade -y
#apt-get install -y nano
find / -perm 6000 -type f -exec chmod a-s {} \; || true

grep "#PS1_found" /root/.bashrc >/dev/null 2>&1 || echo 'export PS1="[${debian_chroot:+($debian_chroot)}\[\033[01;36m\]\u\[\033[m\]\[\033[33m\]@\[\033[m\]\[\033[01;32m\]\h \[\033[33;1m\]\W\[\033[m\]]\[\033[1;31m\]\$\[\033[m\] " #PS1_found' >> /root/.bashrc
