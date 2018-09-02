bid=$1
DPATH=/mnt/disks/traakr/us.bm/VTAG/$bid
dt=$( date -d "yesterday 13:00 " '+%d-%m-%Y' )
mdt=$( date -d "yesterday 13:00 " '+%Y-%m-%d' )

#Extract, Add all columns to the file
awk -v p="|" -F"|" '{print p $2 p $3 p $4 p $5 p $6 p $7}' $DPATH/$dt/psip.csv | sort -nr| uniq -c  >/tmp/$bid-$dt-ufids 
awk -v indate="$mdt" -v b="$bid" -F"|" '{$1='' FS b FS indate FS $1;}1' OFS="|" /tmp/$bid-$dt-ufids >  /tmp/$bid-o-$dt.csv
sudo mv /tmp/$bid-o-$dt.csv $DPATH/$dt/vall$dt.csv
#upoad to google storage
gsutil cp $DPATH/$dt/vall$dt.csv gs://"$bid"csv

#Remove
sudo rm /tmp/o-$dt.csv

#Build suspect traffic data
awk -v p="|" -F"|" '{print p $2 p  $4 p $5 p $6 p $7 p $3 p $10 p $11 p $12 p $13}' $DPATH/$dt/psip.csv |  sort -nr| uniq -c |  egrep -w 'BN|TEN|DC|FC|PWP|KAS|PCP|WS|CB|CS'>/tmp/$bid-$dt-ufsusp 
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
