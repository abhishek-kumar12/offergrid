FPATH=/home/traakr/us.bm/autoscripts/tag
while read bizid
do
#sudo sh $FPATH/push.sh $bizid 
sudo sh $FPATH/push.sh $bizid >> /mnt/disks/logs/$bizid-push.log 2>&1
done < /home/traakr/us.bm/abbid/og_active_bbid.txt
