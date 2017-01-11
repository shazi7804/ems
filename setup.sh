# setup ems
#
# Program: ems setup
# Author: scott
# Github: https://github.com/shazi7804

ems_ver="1.0"
ems_prefix="/opt/ems"


Welcome() {
	echo ""
	echo "----------------------------------------------"
	echo "-  Welcome to use the ems installation tool  -"
	echo "----------------------------------------------"
	echo "This tool will be installed in accordance with the following environment:"
	echo ""
	echo "Version = $ems_ver"
	echo "prefix  = $ems_prefix"
	echo "config  = $ems_config"
	echo "sbin    = $ems_sbin"
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
	echo ""
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
	WorkingStatus Process "Install ems"
	if [ -n $ems_prefix ] && [ -n $ems_ver ]; then
		if [ ! -d $ems_prefix-$ems_ver ]; then
			mkdir -p $ems_prefix-$ems_ver
		fi
		cp -R config sbin $ems_prefix-$ems_ver/
	fi

	if [ -L $ems_prefix ]; then
		unlink $ems_prefix
	fi

	# create softlink
	ln -fs $ems_prefix-$ems_ver $ems_prefix
	if [[ $? -ne 0 ]]; then
		WorkingStatus Fail "Install ems"	
	fi

	chmod 555 $ems_prefix/sbin/ems
	if [[ $? -ne 0 ]]; then
		WorkingStatus Fail "Install ems"
	else
		WorkingStatus OK "Install ems"
	fi

  WorkingStatus Process "Write to ems.conf"
  if [ -f $ems_prefix/config/ems.conf ]; then
  	echo "
# ems configure path
ems_ver="$ems_ver"
ems_prefix="$ems_prefix"
ems_config="$ems_config"
ems_sbin="$ems_sbin"
ems_sitelist="$ems_sitelist"
  	" >> $ems_prefix/config/ems.conf
  	WorkingStatus OK "Write to ems.conf"
  else
  	WorkingStatus Fail "Write to ems.conf"
  fi

  WorkingStatus Process "Write to ems path"
  # add config next line
  sed -i "/ems\ config\ path\,\ not\ deleting\ rows/aems_config\=$ems_config" $ems_sbin/ems
  if [[ $? -ne 0 ]]; then
  	WorkingStatus Fail "Write to ems path"
  else
  	WorkingStatus OK "Write to ems path"
  fi
}


for opt in $@
do
  case $opt in
    --prefix=*)
      shift
      ems_prefix="${opt#*=}"
      ;;
    -h|--help)
      helpmsg
      exit 1
      ;;
  esac
done

ems_config="${ems_prefix}/config/ems.conf"
ems_sbin="${ems_prefix}/sbin"
ems_sitelist="${ems_prefix}/config/site-conf.d"

Welcome
ems_setup

if [[ $? -eq 0 ]]; then
	echo ""
	echo "Installation successful !! You can enjoy the ems."
	echo ""
	echo "Now test your ems tools"
	echo ""
	echo "$ ems --version"
	echo ""
	echo "HowTo use ems: https://github.com/shazi7804/ems"
else
	echo "ems install failed, check your setup.ini"
fi