#Filter Duplicate IPs

bid=$1
DPATH=/mnt/disks/traakr/us.bm/VTAG/$1
ldt=$( date -d "yesterday 13:00 " '+%d-%m-%Y' )
#echo 'd-m-Y'
#read ldt

awk --posix '$1 ~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/' $DPATH/$ldt/ip.csv > /tmp/"$ldt"_cleanip.csv

awk -F, '{print $1","$2","$3","$4}' /tmp/"$ldt"_cleanip.csv > /tmp/"$ldt"_di.csv

sort /tmp/"$ldt"_di.csv | uniq -cd > /tmp/"$ldt"_di.txt

cat /tmp/"$ldt"_di.txt | awk -vOFS=',' '{if ($1>1) {print $2}}' > /tmp/"$ldt"_di-ip-sip.txt

awk -F, '{print $1}' /tmp/"$ldt"_di-ip-sip.txt > /tmp/"$ldt"_di-sip.txt

sudo mv /tmp/"$ldt"_di-sip.txt $DPATH/$ldt/di-sip.txt
