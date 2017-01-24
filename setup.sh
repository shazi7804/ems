#!/bin/bash
#
# Program: ems setup
# Author: shazi
# Github: https://github.com/shazi7804

ems_ver="1.0"
ems_prefix="/usr/local/ems"
ems_USER="root"

Welcome() {
  echo ""
  echo " =============================================="
  echo " == Welcome to use the ems installation tool =="
  echo " =============================================="
  echo "This tool will be installed in accordance with the following environment:"
  echo ""
  echo "OS           = $OSVer"
  echo "version      = $ems_ver"
  echo "prefix       = $ems_prefix"
  echo "config       = $ems_confdir"
  echo "sbin         = $ems_sbin"
  echo "user         = $ems_USER"
  echo ""
  read -n1 -r -p "ems is ready to be installed, press any key to continue..."
  echo ""
}

helpmsg() {
  echo ""
  echo "Usage: $0 [option]"
  echo ""
  echo "option:"
  echo "  --prefix=PATH     set installation prefix."
  echo "                    (default: $ems_prefix)"
  echo "  --user=USER       set default user for login."
  echo ""
}

OSType() {
  if uname | grep CYGWIN &> /dev/null; then
    OSVer="Cygwin"
  elif sw_vers &> /dev/null; then
    OSVer="MacOS"
  elif lsb_release -d | grep CentOS &> /dev/null; then
    OSVer="CentOS"
  elif lsb_release -d | grep Ubuntu &> /dev/null; then
    OSVer="Ubuntu"
  elif lsb_release -d | grep Debian &> /dev/null; then
    OSVer="Debian"
  else
    echo "unsupported OS type,  https://github.com/shazi7804"
    exit 1
  fi
}

WorkingStatus() {
  local rest green red status message
  rest='\033[0m'
  green='\033[033;32m'
  red='\033[033;31m'

  status=$1
  shift
  message=$@

  if [[ "OK" == $status ]]; then
    echo -ne "$message  [${green}OK${rest}]\r"
    echo -ne "\n"
  elif [[ "Fail" == $status ]]; then
    echo -ne "$message  [${green}Fail${rest}]"
    exit 1
  elif [[ "Process" == $status ]]; then
    echo -ne "$message  [..]\r"
  fi
}


ems_setup(){
  if [[ "MacOS" == $OSVer ]]; then
    owner="sudo -u $USER"
  fi

  if [ -d $ems_prefix ]; then
    echo "Directory already exists, ems has been installed?"
    exit 1
  else
    if [[ "MacOS" == $OSVer ]]; then
      echo "OS type is $OSVer .. need permissions."
      sudo echo ""
      sudo install -d -o $USER -m 755 $ems_prefix
    else
      mkdir -p $ems_prefix
    fi
  fi

  WorkingStatus Process "Install ems"
  cp -R config sbin resources $ems_prefix

  if [ -L $ems_prefix ]; then
    unlink $ems_prefix
  fi

  $owner ln -fs $ems_prefix/sbin/ems* /usr/local/bin/
  
  $owner chmod 755 $ems_prefix/sbin/ems
  if [[ $? -ne 0 ]]; then
    WorkingStatus Fail "Install ems"
  else
    WorkingStatus OK "Install ems"
  fi

  WorkingStatus Process "Write to ems.conf"
  if [ -f $ems_config ]; then
    echo "
# ems configure path
ems_ver="$ems_ver"
ems_prefix="$ems_prefix"
ems_confdir="$ems_confdir"
ems_config="$ems_config"
ems_sbin="$ems_sbin"
ems_keydir="$ems_keydir"
ems_sitelist="$ems_sitelist"
ems_resources="$ems_resources"

# Default login user
ems_USER="$ems_USER"

# OS Version
OSType="$OSVer"
    " >> $ems_config
    WorkingStatus OK "Write to ems.conf"
  else
    WorkingStatus Fail "Write to ems.conf"
  fi

  WorkingStatus Process "Write to ems path"
  # add config next line
  if [[ 'MacOS' == $OSVer ]]; then
    sed -i '' "/ems config path/a \\ 
    ems_config\=$ems_config \\
    " $ems_sbin/ems $ems_sbin/ems-config
  elif [[ $OSVer =~ ^(Ubuntu|Debian|CentOS|Cygwin)$ ]]; then
    sed -i "/ems config path/aems_config\=$ems_config" $ems_sbin/ems $ems_sbin/ems-config
  fi
  
  if [[ $? -ne 0 ]]; then
    WorkingStatus Fail "Write to ems path"
  else
    WorkingStatus OK "Write to ems path"
  fi

  # initialize rsa key
  WorkingStatus Process "Initialize ems key"
  test -d $ems_keydir || mkdir -p $ems_keydir
  if [ ! -z $ems_keydir ];then
    ssh-keygen -t rsa -b 4096 -q -f $ems_keydir/ems -P ''
    if [[ $? -eq "0" ]]; then
      WorkingStatus OK "Initialize ems key"
    else
      WorkingStatus Fail "Initialize ems key"
    fi
  fi
}


for opt in $@
do
  case $opt in
    --prefix=*)
      shift
      ems_prefix="${opt#*=}"
      shift
      ;;
    --user=*)
      shift
      ems_USER="${opt#*=}"
      shift
      ;;
    -h|--help)
      helpmsg
      exit 1
      ;;
  esac
done

ems_confdir="${ems_prefix}/config"
ems_config="${ems_confdir}/ems.conf"
ems_sbin="${ems_prefix}/sbin"
ems_keydir="${ems_prefix}/key"
ems_sitelist="${ems_confdir}/site-conf.d"
ems_resources="${ems_prefix}/resources"

OSType
Welcome
ems_setup

echo ""
echo "Installation successful !! You can enjoy the ems."
echo ""
echo "HowTo use ems: https://github.com/shazi7804/ems"
echo ""