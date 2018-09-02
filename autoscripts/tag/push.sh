#!/bin/bash 
dt=$( date -d "yesterday 13:00 " '+%d-%m-%Y' )
bid=$1
LOCAL=/mnt/disks/traakr/us.bm/VTAG/$bid
ZONE=us-central1-f
REMOTE=/mnt/disks/operations/rawlogs/botnet/$bid

gcloud -q compute scp $LOCAL/$dt/ip.txt root@threadserver:$REMOTE/$dt/ip.txt --zone $ZONE
gcloud -q compute scp $LOCAL/$dt/ip.csv root@threadserver:$REMOTE/$dt/ip.csv --zone $ZONE
