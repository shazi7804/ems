#!/bin/bash
#
# Program: ems setup
# Author: shazi
# Github: https://github.com/shazi7804

ems_prefix="/usr/local/ems"

Welcome() {
  echo ""
  echo " =============================================="
  echo " == Welcome to use the ems installation tool =="
  echo " =============================================="
  echo "This tool will be installed in accordance with the following environment:"
  echo ""
  echo "OS           = $OSVer"
  echo "prefix       = $ems_prefix"
  echo "config       = $ems_prefix/config"
  echo "sbin         = $ems_prefix/sbin"
  echo "user         = $USER"
  echo ""
  read -n1 -r -p "ems is ready to be installed, press any key to continue..."
  echo ""
}

helpmsg() {
  echo ""
  echo "Usage: $0 [option]"
  echo ""
  echo "option:"
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
  owner=$(id -nu)
  if [ -d $ems_prefix ]; then
    echo "Directory already exists, ems has been installed?"
    exit 1
  else
    if [[ "MacOS" == $OSVer ]]; then
      echo "OS type is $OSVer .. need permissions."
      sudo echo ""
      sudo install -d -o $owner -m 755 $ems_prefix
    else
      mkdir -p $ems_prefix
    fi
  fi

  WorkingStatus Process "Install ems"
  cp -R config sbin resources $ems_prefix

  if [ -L $ems_prefix ]; then
    unlink $ems_prefix
  fi

  sudo -u $owner ln -fs $ems_prefix/sbin/ems* /usr/local/bin/
  
  sudo -u $owner chmod 755 $ems_prefix/sbin/ems
  if [[ $? -ne 0 ]]; then
    WorkingStatus Fail "Install ems"
  else
    WorkingStatus OK "Install ems"
  fi

  # initialize rsa key
  WorkingStatus Process "Initialize ems key"
  test -d $ems_prefix/key || mkdir -p $ems_prefix/key
  if [ ! -z $ems_prefix/key ];then
    ssh-keygen -t rsa -b 4096 -q -f $ems_prefix/key/ems.secret -P ''
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
    --user=*)
      shift
      USER="${opt#*=}"
      shift
      ;;
    -h|--help)
      helpmsg
      exit 1
      ;;
  esac
done

OSType
Welcome
ems_setup

echo ""
echo "Installation successful !! You can enjoy the ems."
echo ""
echo "HowTo use ems: https://github.com/shazi7804/ems"
echo ""