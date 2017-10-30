#!/bin/sh
# remote commander
# include remote-lib.sh
#
# $1=host
do_remote_command()
{
	echo "[$1]"

	# run command
	ssh $1 "df -h"


	# copy file
	scp web.conf $1:/xxx/

	# install apps
	ssh $1 "sudo apt-get update; sudo apt-get install mysql-client"

	# copy hosts file
        scp /etc/hosts ubuntu@$1:/tmp/
        ssh ubuntu@$1 "sudo mv /etc/hosts /etc/hosts.org;sudo mv /tmp/hosts /etc/"


	echo "Done"
}

USE_CHECK_CMD="N"
# include common library
source remote-lib.sh

