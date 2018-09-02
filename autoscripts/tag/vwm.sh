#####
##Calculate Viewability
clear
bid=$1
ldt=$2
DPATH=/mnt/disks/traakr/us.bm/VTAG/$bid

echo 'Creating Viewability Input Files..'
# Take vw.csv and cut and save data to DB
#bizid, app, date, ip address, session, useragent, correlation, cid, agid, crid, x, y, ih, iw, oh, ow ,ifp,h1,vis,purl
#10081|com.turboc.cleaner|2018-07-15 02:00:03|183.171.66.156|4nouiplckfqnsfna32q2nlbbf7|Mozilla/5.0 (Linux; Android 5.1.1; F1f Build/LMY47V; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/67.0.3396.87 Mobile Safari/537.36|c1|237|1355|0|1H|1H|250|300|250|300|1|1|10|http://ads.mopub.com/
sudo sed -i 's/KHTML,/KHTML/g' $DPATH/$ldt/vw.csv

#Get Total Recordings
#Get Total Recordings view view reasons

#split the file into two
#c1 - viewable(measurable and non-measurable values)
#c0 - non-viewable (non-measurable)

sudo grep '|c1|' $DPATH/$ldt/vw.csv > /tmp/$bid-$ldt-c1.csv
sudo grep '|c0|' $DPATH/$ldt/vw.csv > /tmp/$bid-$ldt-c0.csv
#non-dupe c1. This is temporary till we arrive at a correlation variable in c1
sudo sort /tmp/$bid-$ldt-c1.csv | uniq > /tmp/$bid-$ldt-uniq-c1.csv
# not required for c0

# join the two files
sudo sh -c "cat /tmp/$bid-$ldt-uniq-c1.csv >> /tmp/$bid-$ldt-c0.csv"

#move the file
sudo mv /tmp/$bid-$ldt-c0.csv $DPATH/$ldt/vw-all.csv

#create an app only file where 42mwill fill the details
echo "Populating App data..for Brand Safety Measurement"

awk  -F'|' '{print $2"|" "NA" "|" "NA" "|" "NA" "|" "NA" "|" "NA" }' $DPATH/$ldt/vw.csv >/tmp/$bid-$ldt-app.csv
awk -F'|' '{$1='' FS $1;}1' OFS='|' /tmp/$bid-$ldt-app.csv >  /tmp/$bid-$ldt-app-1.csv

sudo mv /tmp/$bid-$ldt-app-1.csv $DPATH/$ldt/vw-app$ldt.csv
#upload to google storage
gsutil cp $DPATH/$ldt/vw-app$ldt.csv gs://"$bid"csv/vw-app$ldt.csv


#-----------------------------------------------------------------------------------------------------------
echo 'Building the view..'

#10081|com.turboc.cleaner|2018-07-15 02:00:03|183.171.66.156|4nouiplckfqnsfna32q2nlbbf7|Mozilla/5.0 (Linux; Android 5.1.1; F1f Build/LMY47V; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/67.0.3396.87 Mobile Safari/537.36|c1|237|1355|0|1H|1H|250|300|250|300|1|1|10|http://ads.mopub.com/
#Extract, Add all columns to the file on which we want to dimension
#cid, agid, crid, app , ref 
awk  -F'|' '{print "|" $3"|" $8"|"$9"|"$10"|"$2"|"$20}' $DPATH/$ldt/vw-all.csv | sort -nr | uniq -c  >/tmp/$bid-$ldt-vdim.csv
awk -v  b="$bid" -F'|' '{$1='' FS b FS $1;}1' OFS='|' /tmp/$bid-$ldt-vdim.csv >  /tmp/$bid-$ldt-vdim-1.csv

# Replace character pipe with ,
sudo sed -i 's/|/,/g' /tmp/$bid-$ldt-vdim-1.csv
sudo cp /tmp/$bid-$ldt-vdim-1.csv $DPATH/$ldt/vw-vall$ldt.csv

#upload to google storage
gsutil cp $DPATH/$ldt/vw-vall$ldt.csv gs://"$bid"csv/vw-vall$ldt.csv

#-----------------------------------------------------------------------------------------------------------
#Build suspect traffic data 
awk  -F'|' '{print "|"$3"|" $8"|"$9"|"$10"|"$2"|"$20"|"$19"|" "NA"}' $DPATH/$ldt/vw-all.csv |  sort -nr| uniq -c >/tmp/$bid-$ldt-vmet.csv
awk -v b="$bid" -F'|' '{$1='' FS b FS $1;}1' OFS='|' /tmp/$bid-$ldt-vmet.csv >  /tmp/$bid-$ldt-vmet-1.csv

sudo sed -i 's/|/,/g' /tmp/$bid-$ldt-vmet-1.csv
sudo cp /tmp/$bid-$ldt-vmet-1.csv $DPATH/$ldt/vw-vtrap$ldt.csv

gsutil cp $DPATH/$ldt/vw-vtrap$ldt.csv gs://"$bid"csv/vw-vtrap$ldt.csv

#-----------------------------------------------------------------------------------------------------------

DATABASE=botman

TABLE=t_bot_view_ability

C=gs://"$bid"csv/vw-vall"$ldt".csv

D=botman-master-sql

ACCESS_TOKEN="$(sudo gcloud auth application-default print-access-token)"
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" --header 'Content-Type: application/json' --data '{"importContext":
                {"fileType": "csv",
                 "uri": "'$C'",
                 "csvImportOptions": {
      "table": "'$TABLE'"
    },
                 "database": "'$DATABASE'" }}' -X POST https://www.googleapis.com/sql/v1beta4/projects/poetic-primer-844/instances/$D/import


sleep 50

TABLE=t_bot_view_ability_reason

C=gs://"$bid"csv/vw-vtrap"$ldt".csv

D=botman-master-sql

ACCESS_TOKEN="$(sudo gcloud auth application-default print-access-token)"
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" --header 'Content-Type: application/json' --data '{"importContext":
                {"fileType": "csv",
                 "uri": "'$C'",
                 "csvImportOptions": {
                      "table": "'$TABLE'"
    },
                 "database": "'$DATABASE'" }}' -X POST https://www.googleapis.com/sql/v1beta4/projects/poetic-primer-844/instances/$D/import


sleep 10

DATABASE=botman

TABLE=t_bot_bs_app

C=gs://"$bid"csv/vw-app"$ldt".csv

D=botman-master-sql

ACCESS_TOKEN="$(sudo gcloud auth application-default print-access-token)"
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" --header 'Content-Type: application/json' --data '{"importContext":
                {"fileType": "csv",
                 "uri": "'$C'",
                 "csvImportOptions": {
      "table": "'$TABLE'"
    },
                 "database": "'$DATABASE'" }}' -X POST https://www.googleapis.com/sql/v1beta4/projects/poetic-primer-844/instances/$D/import



