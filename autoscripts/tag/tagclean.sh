FPATH=/home/traakr/us.bm/autoscripts/tag
CPATH=/mnt/disks/backup1/CLICKLOGS/
while read bizid
do
sudo rm $CPATH/$bizid/mnt/disks/traakr/asia.bm/VTAG/$bizid/*.*
done < /home/traakr/us.bm/abbid/og_active_bbid.txt
