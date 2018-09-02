bid=$1
DPATH=/mnt/disks/traakr/us.bm/VTAG/$1

dt=$( date -d "yesterday 13:00 " '+%d-%m-%Y' )
#echo 'd-m-Y'
#read dt

   awk --posix '$1 ~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/' $DPATH/$dt/sip.txt > /tmp/"$dt"_cleansip.txt
   sudo mv /tmp/"$dt"_cleansip.txt $DPATH/$dt/cleansip.txt	

   egrep -w 'DC' $DPATH/"$dt"/cleansip.txt > /tmp/dc-sip-$dt.txt
   egrep -w 'BN' $DPATH/"$dt"/cleansip.txt > /tmp/bn-sip-$dt.txt

   sudo cp /tmp/dc-sip-$dt.txt $DPATH/$dt/dc-sip.txt 
   sudo cp /tmp/bn-sip-$dt.txt $DPATH/$dt/bn-sip.txt 
   
   # filter only 256 hosts of BN
   # cut first three columns

   grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' /tmp/bn-sip-$dt.txt > /tmp/3row-bn-sip-$dt.txt
   cat /tmp/3row-bn-sip-$dt.txt | sort | uniq -c > /tmp/count-3row-bn-sip-$dt.txt

   cat /tmp/count-3row-bn-sip-$dt.txt | awk -vOFS='' '{if ($1==256) {print $2,".0/24"}}' > /tmp/256_bn-sip-$dt.txt

   # clean DC column
   
   awk -F, '{print $1}' /tmp/dc-sip-$dt.txt > /tmp/ip-dc-sip-$dt.txt
   
   cat /tmp/ip-dc-sip-$dt.txt /tmp/256_bn-sip-$dt.txt $DPATH/$dt/cs-sip.txt $DPATH/$dt/di-sip.txt > /tmp/join-all-$dt.txt
 
   # uniq it 

   sort /tmp/join-all-$dt.txt | uniq > /tmp/join-sip-$dt.txt	    

   # move it for upload

   mv /tmp/join-sip-$dt.txt $DPATH/$dt/join-sip.txt

   
