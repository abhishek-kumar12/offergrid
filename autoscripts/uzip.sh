###
bid=$1
DPATH=/mnt/disks/traakr/us.bm/VTAG/$1
#dt=$( date -d "yesterday 13:00 " '+%d-%m-%Y' )
ldt=$( date -d "yesterday 13:00 " '+%d-%m-%Y' )

sudo unzip $DPATH/$ldt/"$bid".log.gz




