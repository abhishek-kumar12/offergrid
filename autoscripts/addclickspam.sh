bid=$1
DPATH=/mnt/disks/traakr/us.bm/VTAG/$1
ldt=$( date -d "yesterday 13:00 " '+%d-%m-%Y' )


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
