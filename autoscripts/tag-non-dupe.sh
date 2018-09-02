bid=$1
DPATH=/mnt/disks/traakr/us.bm/VTAG/$bid
ldt=$( date -d "yesterday 13:00 " '+%d-%m-%Y' )
mdt=$( date -d "yesterday 13:00 " '+%Y-%m-%d' )
ldt=16-07-2018
# clean up the files to one line each and then process below

# Process csp.csv

sudo cp $DPATH/$ldt/csp.csv $DPATH/$ldt/csp-to-be-non-duped.csv
cat $DPATH/$ldt/csp-to-be-non-duped.csv | sort | uniq > /tmp/$bid-$ldt-nonduped-clickspam.csv
sudo mv /tmp/$bid-$ldt-nonduped-clickspam.csv $DPATH/$ldt/csp.csv

sudo cp $DPATH/$ldt/ip.csv $DPATH/$ldt/ip-to-be-non-duped.csv
cat $DPATH/$ldt/ip-to-be-non-duped.csv | sort | uniq > /tmp/$bid-$ldt-nonduped-ip.csv
sudo mv /tmp/$bid-$ldt-nonduped-ip.csv $DPATH/$ldt/ip.csv

#sudo rm $DPATH/$ldt/ip-to-be-non-duped.csv
#sudo rm $DPATH/$ldt/csp-to-be-non-duped.csv
