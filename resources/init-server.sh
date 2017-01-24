#!/bin/bash

# include argv
if [[ $1 ]]; then
  ems_USER=$1
  shift
fi

# if [[ $1 ]]; then
#   ems_PASS=$1
#   shift
# fi

if [[ $@ ]]; then
  pubkey=$@
fi

owner="sudo -u $ems_USER"

# create user and password
if ! id $ems_USER &> /dev/null; then
  useradd $ems_USER -m \
  --shell /bin/bash \
  --system \
  --home /home/$ems_USER \
  -k /etc/skel/
elif [ ! -d /home/$ems_USER ] ; then
  install -d -o $ems_USER -m 755 /home/$ems_USER && cp /etc/skel/.* /home/$ems_USER/
fi

# check ems group
if ! grep -q ems /etc/group ; then
  groupadd ems
fi

# join to ems group
if ! getent group ems | grep -q $ems_USER; then
  usermod -a -G ems $ems_USER
fi

# join sudo to /etc/sudoers
if ! grep -P "%ems\ ALL\=\(ALL\)\ NOPASSWD\:\ ALL" /etc/sudoers &> /dev/null; then
  echo "%ems ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
fi

# create ~user/.ssh
if ! $owner ls $(eval echo /home/$ems_USER/.ssh) &> /dev/null; then
  $owner mkdir -p /home/$ems_USER/.ssh
fi

if ! $owner ls /home/$ems_USER/.ssh/authorized_keys &> /dev/null; then
  $owner touch /home/$ems_USER/.ssh/authorized_keys
fi
echo $pubkey > /home/$ems_USER/.ssh/authorized_keys
