bid=$1
DPATH=/mnt/disks/traakr/us.bm/VTAG/$1
#dt=$( date -d "yesterday 13:00 " '+%d-%m-%Y' )
#ldt=$( date -d "yesterday 13:00 " '+%d-%m-%Y' )
#mdt=$( date -d "yesterday 13:00 " '+%Y-%m-%d' )
echo 'd-m-Y'
read ldt
dt=$ldt
echo 'Y-m-d'
read mdt

awk --posix '$1 ~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/' $DPATH/$ldt/ip.csv > /tmp/$bid-"$ldt"_cleanip.csv

awk -F'|' '{print $1"|"$8"|"$9}' /tmp/$bid-"$ldt"_cleanip.csv > /tmp/$bid-"$ldt"_clickspam.csv

sort /tmp/$bid-"$ldt"_clickspam.csv | uniq -cd > /tmp/$bid-"$ldt"_clickspam.txt

cat /tmp/$bid-"$ldt"_clickspam.txt | awk -vOFS='|' '{if ($1>1) {print $2}}' > /tmp/$bid-"$ldt"_cs-ip-sip.txt

awk -F'|' '{print $1}' /tmp/$bid-"$ldt"_cs-ip-sip.txt > /tmp/$bid-"$ldt"_cs-sip.txt

sudo mv /tmp/$bid-"$ldt"_cs-sip.txt $DPATH/$ldt/cs-sip.txt

#prepareblacklist
   awk --posix '$1 ~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/' $DPATH/$dt/sip.txt > /tmp/$bid-"$dt"_cleansip.txt
   sudo mv /tmp/$bid-"$dt"_cleansip.txt $DPATH/$dt/cleansip.txt      

   egrep -w 'DC' $DPATH/"$dt"/cleansip.txt > /tmp/$bid-dc-sip-$dt.txt
   egrep -w 'GB|BN|MW' $DPATH/"$dt"/cleansip.txt > /tmp/$bid-bn-sip-$dt.txt

   sudo cp /tmp/$bid-dc-sip-$dt.txt $DPATH/$dt/dc-sip.txt
   sudo cp /tmp/$bid-bn-sip-$dt.txt $DPATH/$dt/bn-sip.txt  

   # filter only 256 hosts of BN
   # cut first three columns

   grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' /tmp/$bid-bn-sip-$dt.txt > /tmp/$bid-3row-bn-sip-$dt.txt
   cat /tmp/$bid-3row-bn-sip-$dt.txt | sort | uniq -c > /tmp/$bid-count-3row-bn-sip-$dt.txt

   cat /tmp/$bid-count-3row-bn-sip-$dt.txt | awk -vOFS='' '{if ($1==256) {print $2,".0/24"}}' > /tmp/$bid-256_bn-sip-$dt.txt

   # clean DC column
   
   awk -F'|' '{print $1}' /tmp/$bid-dc-sip-$dt.txt > /tmp/$bid-ip-dc-sip-$dt.txt
   
   cat /tmp/$bid-ip-dc-sip-$dt.txt /tmp/$bid-256_bn-sip-$dt.txt $DPATH/$dt/cs-sip.txt > /tmp/$bid-join-all-$dt.txt
 
   # uniq it 

   sort /tmp/$bid-join-all-$dt.txt | uniq > /tmp/$bid-join-sip-$dt.txt        

   # move it for upload

   sudo mv /tmp/$bid-join-sip-$dt.txt $DPATH/$dt/$bid-join-sip.txt

#upload the ip blacklist
sudo cp $DPATH/$dt/$bid-join-sip.txt $DPATH/$dt/n413_botman_ipcidr_"$dt".txt

#upload to gcloud
sudo gsutil cp $DPATH/$dt/n413_botman_ipcidr_"$dt".txt gs://$bid/n413_botman_ipcidr_"$dt".txt
sudo gsutil acl ch -u AllUsers:R gs://$bid/n413_botman_ipcidr_"$dt".txt

#ADD Clickspam to the end

sudo sh -c "grep -Fvf $DPATH/$ldt/cs-sip.txt $DPATH/$ldt/sip.csv > $DPATH/$ldt/cs-parent-psip.csv"
sudo sh -c "grep -Ff $DPATH/$ldt/cs-sip.txt $DPATH/$ldt/sip.csv > $DPATH/$ldt/cs-child-psip.csv"

#add CS to the child sip
sudo sed -i 's/$/|CS/g' $DPATH/$ldt/cs-child-psip.csv 
sudo sed -i 's/$/|NA/g' $DPATH/$ldt/cs-parent-psip.csv 

# now merge it with teh parent
sudo sh -c "cat $DPATH/$ldt/cs-child-psip.csv >> $DPATH/$ldt/cs-parent-psip.csv"

#rename it to psip. if we do more traps then do them before and then finally rename it to psip.csv
sudo mv $DPATH/$ldt/cs-parent-psip.csv $DPATH/$ldt/psip.csv

#Build the View..

#Extract, Add all columns to the file
awk -v p="|" -F"|" '{print p $2 p $3 p $4 p $5 p $6 p $7}' $DPATH/$ldt/psip.csv | sort -nr| uniq -c  >/tmp/$bid-$ldt-ufids
awk -v indate="$mdt" -v b="$bid" -F"|" '{$1='' FS b FS indate FS $1;}1' OFS="|" /tmp/$bid-$ldt-ufids >  /tmp/$bid-o-$ldt.csv
sudo mv /tmp/$bid-o-$ldt.csv $DPATH/$ldt/vall$dt.csv 
sudo sed -i 's/|/,/g' $DPATH/$ldt/vall$ldt.csv
#upoad to google storage
gsutil cp $DPATH/$ldt/vall$ldt.csv gs://"$bid"csv/vall$ldt.csv

#Remove
sudo rm /tmp/$bid-o-$ldt.csv
   
#Build suspect traffic data
awk -v p="|" -F"|" '{print p $2 p  $4 p $5 p $6 p $7 p $3 p $10 p $11 p $12 p $13}' $DPATH/$ldt/psip.csv |  sort -nr| uniq -c |  egrep -w 'WEP|SN|MW|BN|TEN|DC|FC|PWP|KAS|PCP|WS|CB|CS|GB'>/tmp/$bid-$ldt-ufsusp
awk -v indate="$mdt" -v b="$bid" -F, '{$1='' FS b FS indate FS $1;}1' OFS="|" /tmp/$bid-$ldt-ufsusp >  /tmp/$bid-t-$ldt.csv
sudo mv /tmp/$bid-t-$ldt.csv $DPATH/$ldt/vtrap$ldt.csv
sudo sed -i 's/|/,/' $DPATH/$ldt/vtrap$ldt.csv
gsutil cp $DPATH/$ldt/vtrap$ldt.csv gs://"$bid"csv/vtrap$ldt.csv

#Remove 
sudo rm /tmp/$bid-t-$ldt.csv

# import to the SQL

sudo sh /home/traakr/us.bm/autoscripts/importcsv.sh t_bot_view gs://"$bid"csv/vall"$dt".csv
sudo sh /home/traakr/us.bm/autoscripts/importcsv.sh t_bot_view_trap gs://"$bid"csv/vtrap"$dt".csv

#copy files into a folder in the date bucket of ustraakr-proclogs

gsutil cp $DPATH/$dt/psip.csv gs://ustraakr-proclogs/$bid/$dt/psip.csv
gsutil cp $DPATH/$dt/sip.csv gs://ustraakr-proclogs/$bid/$dt/sip.csv
gsutil cp $DPATH/$dt/ip.csv gs://ustraakr-proclogs/$bid/$dt/ip.csv
gsutil cp $DPATH/$dt/ip.txt gs://ustraakr-proclogs/$bid/$dt/ip.txt
gsutil cp $DPATH/$dt/csp.csv gs://ustraakr-proclogs/$bid/$dt/csp.csv

# upload to bigquery as well
sleep 20
bq load --allow_jagged_rows --ignore_unknown_values --source_format=CSV  poetic-primer-844:anlog."$bid"_csp gs://ustraakr-proclogs/$bid/$dt/csp.csv

# delete these files from local

sudo rm $DPATH/$dt/psip.csv
sudo rm $DPATH/$dt/sip.csv
sudo rm $DPATH/$dt/ip.csv
sudo rm $DPATH/$dt/ip.txt
sudo rm $DPATH/$dt/csp.csv




