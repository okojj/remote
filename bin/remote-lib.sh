#!/bin/sh
RSYNC="/usr/bin/rsync --exclude=.svn --exclude=.swp --exclude=.pyc "
SERVERLIST_FILE_PATH="$(dirname ${0})/../conf"

l4_check()
{
	L4_INFO=`rsh -l irteam $1 "/sbin/ifconfig|grep lo:0"`
	if [ "$L4_INFO" == "" ]; then
		echo "L4 out"
	else
		echo "L4 in"
	fi
}

show_usage()
{
	self_name=$(basename ${0})
	echo "Usage 1: $self_name hostname"
	echo "Usage 2: $self_name server_group"
	echo "  example> $self_name server01.web"
	echo "  example> $self_name web.prd"
}

check_command()
{
	echo "*** begin of command ***"
	cat $(basename ${0})|egrep "rsh|RSYNC|nc" | grep -v "#"
	echo "*** end of command ***"
	echo -n "Are you sure - $1 (y/N) ? "
	read CHOICE

	if [ "$CHOICE" != "Y" ] && [ "$CHOICE" != "y" ]; then
		echo "Aborted !"
		exit;
	fi
}


if [ "$1" == "" ]; then
    show_usage
    exit
fi

SERVER_GROUP=$1

SERVERLIST_FILE="${SERVERLIST_FILE_PATH}/${SERVER_GROUP}"
if [ -e $SERVERLIST_FILE ]; then
	SERVER_LIST=`cat $SERVERLIST_FILE`
else
	SERVER_LIST="$1"
fi

if [ "$USE_CHECK_CMD" == "Y" ]; then
	check_command $SERVER_GROUP
fi

for server in $SERVER_LIST
do
	if [ ${server:0:1} != "#" ]; then
		do_remote_command $server
	fi
done
