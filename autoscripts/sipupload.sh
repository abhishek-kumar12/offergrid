bid=7388
DPATH=/mnt/disks/traakr/us.bm/VTAG/7388

dt=$( date -d "yesterday 13:00 " '+%d-%m-%Y' )
#rename the file
sudo cp $DPATH/$dt/join-sip.txt $DPATH/$dt/n413_botman_ipcidr_"$dt".txt

#upload to gcloud
sudo gsutil cp $DPATH/$dt/n413_botman_ipcidr_"$dt".txt gs://7388
sudo gsutil acl ch -u AllUsers:R gs://7388/n413_botman_ipcidr_"$dt".txt
