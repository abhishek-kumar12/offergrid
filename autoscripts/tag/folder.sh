#!/bin/bash 
while read bizid
do
sleep 5
bid=$bizid
LOCAL=/mnt/disks/backup1/CLICKLOGS
#create a folder if not there
mkdir -p $LOCAL/$bid
chmod 767 $LOCAL/$bid

done < /home/traakr/us.bm/abbid/og_active_bbid.txt
