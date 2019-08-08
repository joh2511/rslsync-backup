#!/bin/bash

### Settings  ###
BACKUPDIR="/media/backups"
SOURCE_HOME="/home/rslsync/storage"
SOURCE="documents"
DATUM="$(date +%Y-%m-%d)"

### Backup Script ###
mkdir -p ${BACKUPDIR}
if [ ! -d "${BACKUPDIR}" ]; then
	echo "Backupdir does not exist!";
	exit 1
fi

## Retrieve backup number
firstname=$(find ${BACKUPDIR} -maxdepth 1 -name "${SOURCE}_???_*"|sort|head -n1)
lastname=$(find ${BACKUPDIR} -maxdepth 1 -name "${SOURCE}_???_*"|sort|tail -n1)

backupnr=${lastname##${BACKUPDIR}/${SOURCE}_}
backupnr=${lastname##*${SOURCE}_}
backupnr=${backupnr%%.*}
backupnr=${backupnr//\?/0}
backupnr=${backupnr:0:3}
backupnr=$((10#$backupnr))

## Move backups every 4 weeks
if [ "$[backupnr++]" -ge 28 ]; then
	mkdir -p ${BACKUPDIR}/rotate/
	if [ ! -d "${BACKUPDIR}/rotate/" ]; then
		echo "Failed to create log rotate directory!"
		exit 1
	fi

	firstdate=${firstname##${BACKUPDIR}/${SOURCE}_???_}
	firstdate=${firstdate:0:10}
	mv -v ${firstname} ${BACKUPDIR}/rotate/${SOURCE}_${firstdate}.tar.gz

	if [ $? -ne 0 ]; then
		echo "Failed to move old backups!"
		exit 1
	fi 
	
	rm -fv ${BACKUPDIR}/timestamp.snar
	rm -fv ${BACKUPDIR}/${SOURCE}_???_*.tar.gz
	echo "Backup rotated successfully!";

	backupnr=1
fi

backupnr=000${backupnr}
backupnr=${backupnr: -3}
filename=${SOURCE}_${backupnr}_${DATUM}.tar.gz

## Back it up!
cd ${SOURCE_HOME}
echo "Writing backup to ${filename}"
tar -cpzf ${BACKUPDIR}/${filename} -g ${BACKUPDIR}/timestamp.snar ${SOURCE}
if [ $? -ne 0 ]; then
	echo "Backup failed!";
	exit 1
else
	echo "Backup was successful!";
fi
