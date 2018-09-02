bid=$1
DPATH=/mnt/disks/traakr/us.bm/VTAG/$bid
echo 'd-m-y'
read ldt
# clean up the files to one line each and then process below

# Process csp.csv
# extract cor=c1 separately
sudo cat $DPATH/$ldt/csp.csv | grep cor=c1 | sort | uniq > /tmp/csp-$ldt-c1.csv
sudo cat $DPATH/$ldt/csp.csv | grep cor=c0 > /tmp/csp-$ldt-c0.csv
#,erge
sudo cat /tmp/csp-$ldt-c0.csv /tmp/csp-$ldt-c1.csv > /tmp/csp-$ldt-final.csv
sudo mv /tmp/csp-$ldt-final.csv $DPATH/$ldt/csp.csv
 
# extract cor=c1 separately
sudo cat $DPATH/$ldt/ip.csv | grep cor=c1 | sort | uniq > /tmp/ip-$ldt-c1.csv
sudo cat $DPATH/$ldt/ip.csv | grep cor=c0 > /tmp/ip-$ldt-c0.csv
#,erge
sudo cat /tmp/ip-$ldt-c0.csv /tmp/ip-$ldt-c1.csv > /tmp/ip-$ldt-final.csv
sudo mv /tmp/ip-$ldt-final.csv $DPATH/$ldt/ip.csv
sudo cat $DPATH/$ldt/ip.csv | grep cor=c1 | sort | uniq > /tmp/ip-$ldt-c1.csv
sudo cat $DPATH/$ldt/ip.csv | grep cor=c0 > /tmp/ip-$ldt-c0.csv

# extract cor=c1 separately
sudo cat $DPATH/$ldt/sip.csv | grep cor=c1 | sort | uniq > /tmp/sip-$ldt-c1.csv
sudo cat $DPATH/$ldt/sip.csv | grep cor=c0 > /tmp/sip-$ldt-c0.csv
#,erge
sudo cat /tmp/sip-$ldt-c0.csv /tmp/sip-$ldt-c1.csv > /tmp/sip-$ldt-final.csv
sudo mv /tmp/sip-$ldt-final.csv $DPATH/$ldt/sip.csv
