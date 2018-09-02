bid=$1
DPATH=/mnt/disks/traakr/us.bm/VTAG/$1
#dt=$( date -d "yesterday 13:00 " '+%d-%m-%Y' )
#ldt=$( date -d "yesterday 13:00 " '+%d-%m-%Y' )
#mdt=$( date -d "yesterday 13:00 " '+%Y-%m-%d' )
echo 'd-m-Y'
read ldt
echo 'Y-m-d'
read mdt
dt=$ldt

awk --posix '$1 ~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/' $DPATH/$ldt/ip.csv > /tmp/$bid-"$ldt"_cleanip.csv

awk -F, '{print $1","$8","$9}' /tmp/$bid-"$ldt"_cleanip.csv > /tmp/$bid-"$ldt"_clickspam.csv

sort /tmp/$bid-"$ldt"_clickspam.csv | uniq -cd > /tmp/$bid-"$ldt"_clickspam.txt

cat /tmp/$bid-"$ldt"_clickspam.txt | awk -vOFS=',' '{if ($1>1) {print $2}}' > /tmp/$bid-"$ldt"_cs-ip-sip.txt

awk -F, '{print $1}' /tmp/$bid-"$ldt"_cs-ip-sip.txt > /tmp/$bid-"$ldt"_cs-sip.txt

sudo mv /tmp/$bid-"$ldt"_cs-sip.txt $DPATH/$ldt/cs-sip.txt

#prepareblacklist
   awk --posix '$1 ~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/' $DPATH/$dt/sip.txt > /tmp/$bid-"$dt"_cleansip.txt
   sudo mv /tmp/$bid-"$dt"_cleansip.txt $DPATH/$dt/cleansip.txt      

   egrep -w 'DC' $DPATH/"$dt"/cleansip.txt > /tmp/$bid-dc-sip-$dt.txt
   egrep -w 'BN' $DPATH/"$dt"/cleansip.txt > /tmp/$bid-bn-sip-$dt.txt

   sudo cp /tmp/$bid-dc-sip-$dt.txt $DPATH/$dt/dc-sip.txt
   sudo cp /tmp/$bid-bn-sip-$dt.txt $DPATH/$dt/bn-sip.txt  

   # filter only 256 hosts of BN
   # cut first three columns

   grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' /tmp/$bid-bn-sip-$dt.txt > /tmp/$bid-3row-bn-sip-$dt.txt
   cat /tmp/$bid-3row-bn-sip-$dt.txt | sort | uniq -c > /tmp/$bid-count-3row-bn-sip-$dt.txt

   cat /tmp/$bid-count-3row-bn-sip-$dt.txt | awk -vOFS='' '{if ($1==256) {print $2,".0/24"}}' > /tmp/$bid-256_bn-sip-$dt.txt

   # clean DC column
   
   awk -F, '{print $1}' /tmp/$bid-dc-sip-$dt.txt > /tmp/$bid-ip-dc-sip-$dt.txt
   
   cat /tmp/$bid-ip-dc-sip-$dt.txt /tmp/$bid-256_bn-sip-$dt.txt $DPATH/$dt/cs-sip.txt $DPATH/$dt/di-sip.txt > /tmp/$bid-join-all-$dt.txt
 
   # uniq it 

   sort /tmp/$bid-join-all-$dt.txt | uniq > /tmp/$bid-join-sip-$dt.txt        

   # move it for upload

   mv /tmp/$bid-join-sip-$dt.txt $DPATH/$dt/join-sip.txt

#upload the ip blacklist
sudo cp $DPATH/$dt/$bid-join-sip.txt $DPATH/$dt/n413_botman_ipcidr_"$dt".txt

#upload to gcloud
sudo gsutil cp $DPATH/$dt/n413_botman_ipcidr_"$dt".txt gs://$bid
sudo gsutil acl ch -u AllUsers:R gs://7388/n413_botman_ipcidr_"$dt".txt

#ADD Clickspam to the end

sudo sh -c "grep -Fvf $DPATH/$ldt/cs-sip.txt $DPATH/$ldt/sip.csv > $DPATH/$ldt/cs-parent-psip.csv"
sudo sh -c "grep -Ff $DPATH/$ldt/cs-sip.txt $DPATH/$ldt/sip.csv > $DPATH/$ldt/cs-child-psip.csv"

#add CS to the child sip
sed -i 's/$/|CS/' $DPATH/$ldt/cs-child-psip.csv 
sed -i 's/$/|NA/' $DPATH/$ldt/cs-parent-psip.csv 

#awk -F"|" '{$10="CS"}'1 OFS="|" $DPATH/$ldt/cs-child-psip.csv > /tmp/$bid-cs-child-psip-"$ldt".csv
sudo mv /tmp/$bid-cs-child-psip-"$ldt".csv $DPATH/$ldt/cs-sip.csv

# now merge it with teh parent
sudo sh -c "cat $DPATH/$ldt/cs-sip.csv >> $DPATH/$ldt/cs-parent-psip.csv"

#rename it to psip. if we do more traps then do them before and then finally rename it to psip.csv
sudo mv $DPATH/$ldt/cs-parent-psip.csv $DPATH/$ldt/psip.csv

#Build the View..

#Extract, Add all columns to the file
awk -v p="|" -F"|" '{print p $2 p $3 p $4 p $5 p $6 p $7}' $DPATH/$dt/psip.csv | sort -nr| uniq -c  >/tmp/$bid-$dt-ufids
awk -v indate="$mdt" -v b="$bid" -F"|" '{$1='' FS b FS indate FS $1;}1' OFS="|" /tmp/$bid-$dt-ufids >  /tmp/$bid-o-$dt.csv
sudo mv /tmp/$bid-o-$dt.csv $DPATH/$dt/vall$dt.csv 
#upoad to google storage
gsutil cp $DPATH/$dt/vall$dt.csv gs://"$bid"csv

#Remove
sudo rm /tmp/o-$dt.csv
   
#Build suspect traffic data
awk -v p="|" -F"|" '{print p $2 p  $4 p $5 p $6 p $7 p $3 p $10 p $11 p $12 p $13}' $DPATH/$dt/psip.csv |  sort -nr| uniq -c |  egrep -w 'SN|MW|BN|TEN|DC|FC|PWP|KAS|PCP|WS|CB|CS'>/tmp/$bid-$dt-ufsusp
awk -v indate="$mdt" -v b="$bid" -F, '{$1='' FS b FS indate FS $1;}1' OFS="|" /tmp/$bid-$dt-ufsusp >  /tmp/$bid-t-$dt.csv
sudo mv /tmp/$bid-t-$dt.csv $DPATH/$dt/vtrap$dt.csv
gsutil cp $DPATH/$dt/vtrap$dt.csv gs://"$bid"csv

#Remove 
sudo rm /tmp/$bid-t-$dt.csv

# import to the SQL

sudo sh /home/traakr/us.bm/autoscripts/importcsv.sh t_bot_view gs://"$bid"csv/vall"$dt".csv
sudo sh /home/traakr/us.bm/autoscripts/importcsv.sh t_bot_view_trap gs://"$bid"csv/vtrap"$dt".csv

#copy files into a folder in the date bucket of ustraakr-proclogs

gsutil cp $DPATH/$dt/psip.csv gs://ustraakr-proclogs/$bid/$dt/psip.csv
gsutil cp $DPATH/$dt/sip.csv gs://ustraakr-proclogs/$bid/$dt/sip.csv
gsutil cp $DPATH/$dt/ip.csv gs://ustraakr-proclogs/$bid/$dt/ip.csv
gsutil cp $DPATH/$dt/ip.txt gs://ustraakr-proclogs/$bid/$dt/ip.txt

# delete these files from local

sudo rm $DPATH/$dt/psip.csv
sudo rm $DPATH/$dt/sip.csv
sudo rm $DPATH/$dt/ip.csv
sudo rm $DPATH/$dt/ip.txt

