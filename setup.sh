# setup ems
#
# Program: ems setup work
# Author: scott
# Github: https://github.com/shazi7804
trap 'stop' SIGUSR1 SIGINT SIGHUP SIGQUIT SIGTERM SIGSTOP

stop() {
    exit 0
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

initialize(){
	local ini	
	# check setup.ini
	ini=$ems_local/$1
	shift

	if [[ -n $ini ]]; then
		source $ini
	else
		echo "ems warn: Initialization failed, \"$ini\" configuration file does not exist."
		exit 1
	fi

	# check root access
	if [[ "$EUID" -ne 0 ]]; then
		echo -e "Sorry, you need to run this as root"
		exit 1
	fi
}


Welcome() {
	echo ""
	echo "----------------------------------------------"
	echo "-  Welcome to use the ems installation tool  -"
	echo "----------------------------------------------"
	echo "This tool will be installed in accordance with the following environment:"
	echo ""
	echo "ems_sbin=$ems_sbin"
	echo "ems_config=$ems_config"
	echo ""
	read -n1 -r -p "ems is ready to be installed, press any key to continue..."
	echo ""
}

ems_setup(){
	local exconfig exsbin exlib
	exconfig=$ems_local/example-config
	exsbin=$ems_local/sbin
	exlib=$ems_local/lib

	WorkingStatus Process "Install ems"
	if [[ -n $ems_postfix ]] && [[ -n $ems_version ]]; then
		if [[ ! -d $ems_postfix-$ems_version ]]; then
			mkdir -p $ems_postfix-$ems_version
		fi
		cp -R $exconfig $exsbin $exlib $ems_postfix-$ems_version/
	fi

	if [[ -L $ems_postfix ]]; then
		rm $ems_postfix
	fi

	# create softlink
	ln -fs $ems_postfix-$ems_version $ems_postfix
	if [[ $? -ne 0 ]]; then
		WorkingStatus Fail "Install ems"	
	fi

	chmod 500 $ems_postfix/sbin/ems*
	ln -fs $ems_postfix/sbin/ems /usr/sbin/
	ln -fs $ems_postfix/sbin/ems-keygen /usr/sbin/
	if [[ $? -ne 0 ]]; then
		WorkingStatus Fail "Install ems"
	fi

	# copy config
	if [[ ! -d $ems_config ]]; then
		mkdir -p $ems_config
	fi
	cp -R $exconfig/* $ems_config/

	WorkingStatus OK "Install ems"

}

ems_local=$(pwd)

initialize setup.ini
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
else
	echo "ems install failed, check your setup.ini"
fi