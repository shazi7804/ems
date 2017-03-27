#!/bin/bash
#
# Program: ems setup
# Author: shazi
# Github: https://github.com/shazi7804

PREFIX="/usr/local/ems"

Welcome() {
  echo ""
  echo " =============================================="
  echo " == Welcome to use the ems installation tool =="
  echo " =============================================="
  echo "This tool will be installed in accordance with the following environment:"
  echo ""
  echo "OS           = $OSVer"
  echo "prefix       = $PREFIX"
  echo "config       = $PREFIX/config"
  echo "sbin         = $PREFIX/sbin"
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
  echo "  --add-user=USER       only add new user"
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

# setup only owner user
Setup(){
  OWNER=$(id -nu)

  # init ems prefix
  if [ -d $PREFIX ]; then
    echo "Directory already exists, ems has been installed?"
    exit 1
  else
    if [[ "MacOS" == $OSVer ]]; then
      echo "OS type is $OSVer .. need permissions."
      sudo echo ""
      sudo install -d -o $OWNER -m 755 $PREFIX
    else
      sudo mkdir -p $PREFIX
    fi
  fi

  # init ems setting
  WorkingStatus Process "Install ems"
  sudo cp -R config sbin resources $PREFIX

  if [ -L $PREFIX ]; then
    unlink $PREFIX
  fi

  if [[ $? -ne 0 ]]; then
    WorkingStatus Fail "Install ems"
  else
    WorkingStatus OK "Install ems"
  fi
  GenUser $OWNER
}

GenUser(){
  # initialize rsa key
  GENUSER=$1
  GENUSER_HOME=$(eval echo "~${GENUSER}")
  WorkingStatus Process "Initialize ${GENUSER}"
  # init user setting
  test -d ${GENUSER_HOME}/.ems || mkdir -p ${GENUSER_HOME}/.ems
tee -a ${GENUSER_HOME}/.ems/ems.conf <<EOF
ems_USER=$GENUSER
EOF

  # init key
  test -d ${GENUSER_HOME}/.ems/key || mkdir -p ${GENUSER_HOME}/.ems/key
  ssh-keygen -t rsa -b 4096 -q -f ${GENUSER_HOME}/.ems/key/${GENUSER}.secret -P ''
  if [[ $? -eq "0" ]]; then
    WorkingStatus OK "Initialize ${GENUSER}"
  else
    WorkingStatus Fail "Initialize ${GENUSER}"
  fi
}


for opt in $@
do
  case $opt in
    --add-user=*)
      shift
      USER="${opt#*=}"
      GenUser $USER
      ;;
    -h|--help)
      helpmsg
      exit 1
      ;;
  esac
done

OSType
Welcome
Setup

echo ""
echo "Installation successful !! You can enjoy the ems."
echo ""
echo "HowTo use ems: https://github.com/shazi7804/ems"
echo ""