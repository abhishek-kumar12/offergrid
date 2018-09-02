FPATH=/home/traakr/us.bm/autoscripts/tag
while read bizid
do
sudo sh $FPATH/tag-clickspam.sh $bizid  >> /mnt/disks/logs/$bizid-tcs.log 2>&1
done < /home/traakr/us.bm/abbid/og_active_bbid.txt
