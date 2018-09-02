###
echo 'd-m-Y'
read ldt
dt=$ldt
while read bizid
do

bid=$bizid
DPATH=/mnt/disks/traakr/us.bm/VTAG/$bid
CPATH=/mnt/disks/backup1/CLICKLOGS/$bid


sudo gunzip -d $CPATH/"$ldt".log.gz
done < /home/traakr/us.bm/og_active_bbid.txt




