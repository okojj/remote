#!/bin/bash
###############################################################################
# sync file(s) to other server(s) using rsync
# 2006.01.09 by puchon
#
# ex)
# sync2server.sh index.html <enter>  : sync index.html to default servers
# sync2server.sh index.html hostname <enter> : sync index.html to hostname 
# sync2server.sh images/  <enter> : sync images folder 
###############################################################################
BASE_PATH="{replace_base_path}";
SERVER_LIST_FILE="$BASE_PATH/webserver.list"
CHECK_SERVER="web01.prd";
LOG_FILE_DATE=`date +%Y%m`;
LOG_FILE="${BASE_PATH}/log/sync2server_${LOG_FILE_DATE}.log"

# Make Server List
for host in `cat $SERVER_LIST_FILE`
do
	if [ ${host:0:1} != "#" ]; then
		SERVER_LIST="$SERVER_LIST $host"
	fi
done

CURRENT_PATH=`pwd -P`;
RSYNC="/usr/bin/rsync";
RSYNC_OPT_CHECK=" --exclude=CVS --exclude=.git --exclude=_compile --exclude=core.* --exclude=.* --exclude=*.back --suffix=.back";
RSYNC_OPT_SYNC="--delete $RSYNC_OPT_CHECK";


###############################################################################
sync2host()
{
	echo "*********************************************"
	echo "Sync to $1..."
	echo "*********************************************"
	$RSYNC -abvl $RSYNC_OPT_SYNC $SOURCE_PATH  $1::home/web/$TARGET_PATH
	echo ""
}
###############################################################################

if [ "$1" == "" ]; then
	self_name=$(basename ${0})
	#self_fullpath=$(readlink -f ${0})
	#self_dir=$(dirname ${self_fullpath})
	echo ""
	echo "Usage: $self_name FILENAME [hostname]"
	echo ""
	exit
fi

FILE=$1

###############################################################################
# . 으로 시작하는 상대경로 금지 (차후 지원)
###############################################################################
if [ ${FILE:0:3} == "../" ] || [ ${FILE:0:2} == "./" ]; then
	echo "Invalid path"
	exit
fi

###############################################################################
# 파일 경로 계산
###############################################################################
if [ ${FILE:0:1} == "/" ]; then
	SOURCE_PATH=$FILE
else 
	SOURCE_PATH="$CURRENT_PATH/$FILE"
fi

# correct link path
if [ ${SOURCE_PATH:0:7} == "/home" ]; then
	SOURCE_PATH="/home1/ubuntu"$SOURCE_PATH
fi

###############################################################################
# 기본 경로 체크
###############################################################################
if [ `expr match "$SOURCE_PATH" "$BASE_PATH"` == 0 ]; then
	echo "Current :" $SOURCE_PATH
	echo "You can sync file or dir under [$BASE_PATH]"
	echo ""
	exit
fi

###############################################################################
# 파일/폴더 존재 여부 체크
###############################################################################
if [ ! -e $SOURCE_PATH ]; then
	echo "[$SOURCE_PATH] does not exist !"
	exit
fi

###############################################################################
# 폴더인데 마지막에 / 가 없을 경우 추가
###############################################################################
if [ -d $SOURCE_PATH ]; then
	SOURCE_LEN=`expr length $SOURCE_PATH`
	if [ ${SOURCE_PATH:$SOURCE_LEN-1:1} != "/" ]; then
		SOURCE_PATH="$SOURCE_PATH/"
	fi
fi


###############################################################################
# Target Host
###############################################################################
if [ "$2" != "" ]; then
	HOST=$2
else
	HOST="ALL"
fi

TARGET_PATH=${SOURCE_PATH#$BASE_PATH}

###############################################################################
# confirm
###############################################################################
# check changes to CHECK_SERVER first
echo "*********************************************"
echo " Please check below file(s) ... "
echo "*********************************************"
$RSYNC -rnvl $RSYNC_OPT_CHECK  $SOURCE_PATH  $CHECK_SERVER::home/web$TARGET_PATH
echo ""

if [ "$3" == "" ]; then
	echo -n "Are you sure [$SOURCE_PATH] to $HOST (y/N) ? "
	read CHOICE
else
	CHOICE="$3"
fi

if [ "$CHOICE" != "Y" ] && [ "$CHOICE" != "y" ]; then
	echo "Aborted !"
	exit;
fi

###############################################################################
# rsync
###############################################################################
echo [`date +%Y-%m-%d\ %H:%M:%S`] $SOURCE_PATH $2 $3 >> $LOG_FILE

if [ $HOST != "ALL" ]; then
	sync2host $HOST
else
	for host in $SERVER_LIST; do
		sync2host $host
	done;
fi
