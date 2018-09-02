bid=$1
DPATH=/mnt/disks/traakr/us.bm/VTAG/$bid
ldt=$( date -d "yesterday 13:00 " '+%d-%m-%Y' )
clear
echo 'Creating Viewability Input Files..'
ldt='15-07-2018'
# Take vw.csv and cut and save data to DB
#bizid, app, date, ip address, session, useragent, correlation, cid, agid, crid, x, y, ih, iw, oh, ow ,ifp,h1,vis,purl
#10081|com.turboc.cleaner|2018-07-15 02:00:03|183.171.66.156|4nouiplckfqnsfna32q2nlbbf7|Mozilla/5.0 (Linux; Android 5.1.1; F1f Build/LMY47V; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/67.0.3396.87 Mobile Safari/537.36|c1|237|1355|0|1H|1H|250|300|250|300|1|1|10|http://ads.mopub.com/
sudo sed -i 's/KHTML,/KHTML/g' $DPATH/$ldt/vw.csv

#Get Total Recordings
#Get Total Recordings view view reasons

cat $DPATH/$ldt/vw.csv | awk -F'|' '{ print $1","$2","$3"," $4","$5","$6","$7","$11","$12","$13","$14","$15","$16","$17","$18","$19","$20}' >/tmp/$bid-$ldt-met.csv

sudo mv /tmp/$bid-$ldt-dim.csv $DPATH/$ldt/vw-dim.csv
sudo mv /tmp/$bid-$ldt-met.csv $DPATH/$ldt/vw-met.csv




