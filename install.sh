#!/bin/bash

cp -v rslsync-backup.service /etc/systemd/system/
cp -v rslsync-backup.timer /etc/systemd/system/
cp -v rslsync-backup.sh /usr/local/bin


systemctl daemon-reload
systemctl enable rslsync-backup.timer
#systemctl start rslsync-backup

