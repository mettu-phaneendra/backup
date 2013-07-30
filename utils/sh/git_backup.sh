#!/usr/bin/bash

GLOBAL_PMETTU="/home/pmettu/work/global-platform-pmettu/"
BACKUP_BASE_DIR="/home/pmettu/backup/"
BACKUP_DIR=$BACKUP_BASE_DIR`date +%Y%m%d`
NEW_DIR="$BACKUP_DIR/new/"
MOD_DIR="$BACKUP_DIR/mod/"
MIN_ARGS=1
LOG_FILE=$BACKUP_DIR"/change.log"

touch $LOG_FILE
exec >  >(tee -a $LOG_FILE)
exec 2> >(tee -a $LOG_FILE >&2)

if [[ $# -lt $MIN_ARGS ]] ; then 
	echo "Usage: backup.sh [mod] [new]"
	exit
fi	

if [ ! -d "$BACKUP_DIR" ]; then
	mkdir $BACKUP_DIR
	if [[ $? != 0 ]] ; then
	    exit $?
	fi
	touch $LOG_FILE
fi
printf "\n"
echo "-----------------------------";
date
echo "-----------------------------";

cd $GLOBAL_PMETTU
for arg in "$@"
do
	case "$arg" in
		"mod" )
			printf "\n";
			echo "-----------------------";
			echo "Backing modified files :";
			echo "-----------------------";
			if [ ! -d "$BACKUP_DIR/mod" ]; then
				mkdir "$BACKUP_DIR/mod"
				if [[ $? != 0 ]] ; then
				    exit $?
				fi
			fi
			count=1
			for git_file in `git ls-files -m`; do
				echo "Modified $count:" $git_file;
				cp $git_file $MOD_DIR`basename $git_file`$count-`date +%T%p`
				#echo cp $git_file $MOD_DIR`basename $git_file`$count-`date +%T%p`
				let count=count+1;
			done;; 

		"new" ) 
			printf "\n\n"
			echo "------------------";
			echo "Backing new files :";
			echo "------------------";
			if [ ! -d "$BACKUP_DIR/new" ]; then
				mkdir "$BACKUP_DIR/new"
				if [[ $? != 0 ]] ; then
				    exit $?
				fi
			fi
			count=1
			for git_file in `git ls-files --other --exclude-standard`; do
				echo "New $count:" $git_file;
				cp $git_file $NEW_DIR`basename $git_file`$count-`date +%T%p`
				#echo cp $git_file $MOD_DIR`basename $git_file`$count-`date +%T%p`
				let count=count+1;
			done;;
	esac
done;


