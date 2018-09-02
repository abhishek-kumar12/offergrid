###
CPATH=/mnt/disks/backup1/CLICKLOGS/
echo $CPATH
dt=$( date -d "yesterday 13:00 " '+%d-%m-%Y' )
echo $dt
while read bizid
do
bid=$bizid
echo $bid
sudo tar -xzvf $CPATH/$bid/"$dt".log.tar.gz -C $CPATH/$bid/
#return
done < /home/traakr/us.bm/abbid/og_active_bbid.txt
