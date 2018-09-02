bid=$1
DPATH=/mnt/disks/traakr/us.bm/VTAG/$bid
CSVPATH=/mnt/disks/backup1/CLICKLOGS/$bid
ft=$( date -d "yesterday 13:00 " '+%d-%m-%Y' )
dt=$( date -d "yesterday 13:00 " '+%Y-%m-%d' )
ldt=$( date -d "yesterday 13:00 " '+%Y%m%d' )
#echo 'ft d-m-y'
#read ft
#echo 'dt y-m-d'
#read dt
#echo 'ldt -ymd'
#read ldt

#create folder
sudo mkdir  -p $DPATH/$ft
#echo 'Building ip.txt..'
# create ip.txt
awk -F, '{gsub(/"/, "", $9); print $9}' $CSVPATH/$ft/*$ldt*.csv > /tmp/$bid-$ldt-ip1.txt 
grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' /tmp/$bid-$ldt-ip1.txt > /tmp/$bid-$ldt-ip2.txt 
cat /tmp/$bid-$ldt-ip2.txt | sort | uniq > /tmp/$bid-$ldt-ip3.txt 
sudo mv /tmp/$bid-$ldt-ip3.txt $DPATH/$ft/ip.txt 
rm /tmp/$bid-$ldt-ip1.txt
rm /tmp/$bid-$ldt-ip2.txt
#
# create ua.txt
#echo 'Building ua.txt..'
#awk -F, '{print $11}' $CSVPATH/$ft/*$ldt*.csv > /tmp/$bid-$ldt-ua.txt 
#cat /tmp/$bid-$ldt-ua.txt | sort | uniq > /tmp/$bid-$ldt-ua-2.txt 
#sudo mv /tmp/$bid-$ldt-ua-2.txt $DPATH/$ft/ua.txt 

# create erf.txt
#awk -F, '{print $10}' $CSVPATH/$ft/*$ldt*.csv > /tmp/$ldt-ua.txt >> /mnt/disks/logs/audit.log 2>>&1
#cat /tmp/$ldt-ua.txt | sort | uniq > /tmp/$ldt-ua-2.txt >> /mnt/disks/logs/audit.log 2>>&1
#sudo mv /tmp/$ldt-ua-2.txt $DPATH/$ft/ua.txt >> /mnt/disks/logs/audit.log 2>>&1

#create ip.csv
echo 'Building ip.csv..'
awk -v p="|" -v n="NA" -F, '{gsub(/"/, "", $0); print $9 p $3 p $4 p $5 p n p n p $10 p $1 p $2}' $CSVPATH/$ft/*$ldt*.csv > /tmp/$bid-$ldt-ip1.csv 
tr -d '"' < /tmp/$bid-$ldt-ip1.csv> /tmp/$bid-$ldt-ip2.csv
awk '{if(NR>1)print}' /tmp/$bid-$ldt-ip2.csv > /tmp/$bid-$ldt-ip3.csv
sudo mv /tmp/$bid-$ldt-ip3.csv $DPATH/$ft/ip.csv 
rm /tmp/$bid-$ldt-ip1.csv
rm /tmp/$bid-$ldt-ip2.csv
sudo sed -i 's/,/-/g' $DPATH/$ft/ip.csv

#create csp.csv
#echo 'Building csp.csv'
#sudo sed -i 's/KHTML,/KHTML/g' $CSVPATH/$ft/*$ldt*.csv
#awk -v p="|" -v n="NA" -F, '{gsub(/"/, "", $0); print $9 p $2 p $1 p $11 p n $10 p $6 p $3 p $4 p $5 p $7 p $8 p $12 p $13}' $CSVPATH/$ft/*$ldt*.csv > /tmp/$bid-$ldt-csp1.csv 
#tr -d '"' </tmp/$bid-$ldt-csp1.csv> /tmp/$bid-$ldt-csp2.csv
#awk '{if(NR>1)print}' /tmp/$bid-$ldt-csp2.csv > /tmp/$bid-$ldt-csp3.csv
#sudo mv /tmp/$bid-$ldt-csp3.csv $DPATH/$ft/csp.csv
#rm /tmp/$bid-$ldt-csp1.csv
#rm /tmp/$bid-$ldt-csp2.csv

#sudo sed -i 's/KHTML,/KHTML/g' $DPATH/$ft/csp.csv
#sudo sed -i 's/,/-/g' $DPATH/$ft/csp.csv

#create ua.csv
#awk -v p="|" -v n="NA" -F, '{gsub(/"/, "", $0); print $11 p $3 p $4 p $5}' $CSVPATH/$ft/*$ldt*.csv > /tmp/$bid-$ldt-ua.csv 
#sudo mv /tmp/$bid-$ldt-ua.csv $DPATH/$ft/ua.csv >> /mnt/disks/logs/audit.log 2>>&1

#create ref.csv
#awk -F, '{print $10","$3","$4","$5",""NA","NA","NA"}' $CSVPATH/$ft/*$ldt*.csv > /tmp/$ldt-ref.csv >> /mnt/disks/logs/audit.log 2>>&1
#sudo mv /tmp/$ldt-ref.csv $DPATH/$ft/ref.csv 
