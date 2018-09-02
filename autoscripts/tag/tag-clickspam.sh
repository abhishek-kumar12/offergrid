bid=$1
DPATH=/mnt/disks/traakr/us.bm/VTAG/$bid
ldt=$( date -d "yesterday 13:00 " '+%d-%m-%Y' )
mdt=$( date -d "yesterday 13:00 " '+%Y-%m-%d' )

if ([ -f $DPATH/$ldt/sip.csv.tgz ] ); then
        echo "Unzipping TARGZ file sip.csv.tgz"
        sudo tar -zxvf $DPATH/$ldt/sip.csv.tgz
        wget "http://click.traakr.com/state/index.php?bizid=$bid&state=SUCCESS-:SIPS_TAR_RXED_FOR_POSTPROCESSING&server=USTRAAKR-1"
else
        echo "Checking root base file, sip.csv.."
        if ([ ! -f $DPATH/$ldt/sip.csv ]); then
            echo "Mandatory Root file not found..!"
            echo "Suggestion is to download from google cloud, in case you have a copy there"
            echo "Copy? (y/n)"
            copy="y"
            if [ "$copy" = "y" ]; then
                gsutil cp gs://ustraakr-proclogs/$bid/$ldt/sip.csv $DPATH/$ldt/sip.csv
                gsutil cp gs://ustraakr-proclogs/$bid/$ldt/sip.txt $DPATH/$ldt/sip.txt
                gsutil cp gs://ustraakr-proclogs/$bid/$ldt/csip.csv $DPATH/$ldt/csp.csv
                gsutil cp gs://ustraakr-proclogs/$bid/$ldt/ip.csv $DPATH/$ldt/ip.csv
            else
                wget "http://click.traakr.com/state/index.php?bizid=$bid&state=ERROR-:SIPS_NOT_RXED_FOR_POSTPROCESSING&server=USTRAAKR-1"
                echo "so long.. bye"
                exit
            fi

            if ([ ! -f $DPATH/$ldt/sip.csv ]); then
                echo "sip.csv not found in tgz or csv format.."
                echo "Trying to fetch it from the Engine.."
                REMOTE=/mnt/disks/operations/traplogs/iptrap/$bid
                ZONE=us-central1-f
                rx=0
                gcloud -q compute scp root@threadserver:$REMOTE/$ldt/sip.csv $DPATH/$ldt/sip.csv --zone $ZONE
                gcloud -q compute scp root@threadserver:$REMOTE/$ldt/sip.txt $DPATH/$ldt/sip.txt --zone $ZONE
            else
                echo "Root Base sip.csv found. Proceeding.. "
                rx=1
                wget "http://click.traakr.com/state/index.php?bizid=$bid&state=SUCCESS-SIPS_RXED_FROM_GCLOUD_POSTPROCESSING&server=USTRAAKR-1"
            fi

            if ([ "$rx" -eq 0 ]); then
                if ([ ! -f $DPATH/$ldt/sip.csv ]); then
                        echo "File not available anywhere. Exiting.."
                        wget "http://click.traakr.com/state/index.php?bizid=$bid&state=ERROR-SIPS_NOT_FOUND_ANYWHERE_FOR_POSTPROCESSING&server=USTRAAKR-1"
                        exit;
                else
                echo "Root Base sip.csv found. Proceeding.. "
                wget "http://click.traakr.com/state/index.php?bizid=$bid&state=SUCCESS-SIPS_PULLED_FROM_ENGINE_POSTPROCESSING&server=USTRAAKR-1"
                fi
            fi
        else
 		echo "Got the file.. Proceeding."
                wget "http://click.traakr.com/state/index.php?bizid=$bid&state=SUCCESS-SIPS_CSV_RXED_FROM_ENGINE_POSTPROCESSING&server=USTRAAKR-1"
        fi

fi

# Creating IPs of clickspam
#-----------------------------------------------------------------------------------------------------------
sudo cp $DPATH/$ldt/csp.csv /tmp/$bid-$ldt_clickspam.csv
sort /tmp/$bid-$ldt_clickspam.csv | uniq -cd > /tmp/$bid-$ldt_clickspam.txt
cat /tmp/$bid-$ldt_clickspam.txt | awk -vOFS='|' '{if ($1>1) {print $2}}' > /tmp/$bid-$ldt_cs-ip-sip.txt
awk -F'|' '{print $1}' /tmp/$bid-$ldt_cs-ip-sip.txt > /tmp/$bid-$ldt_cs-sip.txt
sudo mv /tmp/$bid-$ldt_cs-sip.txt $DPATH/$ldt/cs-sip.txt
#-----------------------------------------------------------------------------------------------------------
echo 'Building psip.csv'
sudo rm $DPATH/$ldt/cs-child-psip.csv
sudo rm $DPATH/$ldt/psip.csv

#split the cs-sip.txt into two
#parent without the cs ips
#child with the cs ips

sudo sh -c "grep -Fvf $DPATH/$ldt/cs-sip.txt $DPATH/$ldt/sip.csv > $DPATH/$ldt/cs-parent-psip.csv"
sudo sh -c "grep -Ff $DPATH/$ldt/cs-sip.txt $DPATH/$ldt/sip.csv > $DPATH/$ldt/cs-child-psip.csv"

#add CS to the child sip / last field
sudo sed -i 's/$/|CS/g' $DPATH/$ldt/cs-child-psip.csv 
sudo sed -i 's/$/|NA/g' $DPATH/$ldt/cs-parent-psip.csv 

# now merge it with teh parent
sudo sh -c "cat $DPATH/$ldt/cs-child-psip.csv >> $DPATH/$ldt/cs-parent-psip.csv"

#rename it to psip. if we do more traps then do them before and then finally rename it to psip.csv
sudo cp $DPATH/$ldt/cs-parent-psip.csv $DPATH/$ldt/psip.csv

#-----------------------------------------------------------------------------------------------------------
echo 'Building the view..'
sudo rm /tmp/$bid-$ldt-ufids
sudo rm /tmp/$bid-o1-$ldt.csv
sudo rm $DPATH/$ldt/vall$ldt.csv

#Extract, Add all columns to the file on which we want to dimension
#utmsource, utmmedium and remote/advertiser filter
awk  -F'|' '{print "|"$2"|"$3"|"$4"|"$5"|"$6}' $DPATH/$ldt/psip.csv | sort -nr| uniq -c  >/tmp/$bid-$ldt-ufids
awk -v indate="$mdt" -v b="$bid" -F'|' '{$1='' FS b FS indate FS $1;}1' OFS='|' /tmp/$bid-$ldt-ufids >  /tmp/$bid-o-$ldt.csv

# remove invlid utf-8 charcters
iconv -f utf-8 -t ascii -c < /tmp/$1-o-$ldt.csv >  /tmp/$bid-o1-$ldt.csv
# Replace character pipe with ,

sudo sed -i 's/,/-/g' /tmp/$bid-o1-$ldt.csv
sudo sed -i 's/KHTML,/KHTML/g' /tmp/$bid-o1-$ldt.csv
sudo sed -i 's/|/,/g' /tmp/$bid-o1-$ldt.csv
sudo cp /tmp/$bid-o1-$ldt.csv $DPATH/$ldt/vall$ldt.csv

#upload to google storage
gsutil cp $DPATH/$ldt/vall$ldt.csv gs://"$bid"csv/vall$ldt.csv

sudo rm /tmp/$bid-$ldt-ufusp
sudo rm /tmp/$bid-t-$ldt.csv
sudo rm $DPATH/$ldt/vtrap$ldt.csv

#-----------------------------------------------------------------------------------------------------------
#Build suspect traffic data 
awk  -F'|' '{print "|"$2"|"$3"|"$4"|"$5"|"$6"|""NA""|"$10"|"$12"|"$13"|""NA"}' $DPATH/$ldt/psip.csv |  sort -nr| uniq -c |  egrep -w 'GB|WEP|SN|MW|BN|TEN|DC|FC|PWP|KAS|PCP|WS|CB|CS'>/tmp/$bid-$ldt-ufsusp
awk -v indate="$mdt" -v b="$bid" -F'|' '{$1='' FS b FS indate FS $1;}1' OFS='|' /tmp/$bid-$ldt-ufsusp >  /tmp/$bid-t-$ldt.csv
#awk -F, '{$(NF+1)=$4 FS $5 FS $6 ;}1' OFS=, /tmp/t-$dt.csv > /tmp/t1-$dt.csv

# remove invlid utf-8 charcters
iconv -f utf-8 -t ascii -c < /tmp/$1-t-$ldt.csv > /tmp/$bid-t1-$ldt.csv

#replace character pipe with ,

sudo sed -i 's/KHTML,/KHTML/g' /tmp/$bid-t1-$ldt.csv
sudo sed -i 's/|/,/g' /tmp/$bid-t1-$ldt.csv
sudo cp /tmp/$bid-t1-$ldt.csv $DPATH/$ldt/vtrap$ldt.csv

gsutil cp $DPATH/$ldt/vtrap$ldt.csv gs://"$bid"csv/vtrap$ldt.csv

#Remove 
sudo rm /tmp/$bid-t-$ldt.csv

#-----------------------------------------------------------------------------------------------------------
sleep 60
DATABASE=botman

TABLE=t_bot_view

C=gs://"$bid"csv/vall"$ldt".csv

D=botman-master-sql

ACCESS_TOKEN="$(sudo gcloud auth application-default print-access-token)"
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" --header 'Content-Type: application/json' --data '{"importContext":
                {"fileType": "csv",
                 "uri": "'$C'",
                 "csvImportOptions": {
      "table": "'$TABLE'"
    },
                 "database": "'$DATABASE'" }}' -X POST https://www.googleapis.com/sql/v1beta4/projects/poetic-primer-844/instances/$D/import


sleep 80 

TABLE=t_bot_view_trap

C=gs://"$bid"csv/vtrap"$ldt".csv

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
#copy files into a folder in the date bucket of ustraakr-proclogs

sudo sed -i 's/KHTML,/KHTML/g' $DPATH/$ldt/csp.csv
sudo sed -i 's/|/,/g' $DPATH/$ldt/csp.csv

gsutil cp $DPATH/$ldt/psip.csv gs://ustraakr-proclogs/$bid/$ldt/psip.csv
gsutil cp $DPATH/$ldt/sip.csv gs://ustraakr-proclogs/$bid/$ldt/sip.csv
gsutil cp $DPATH/$ldt/ip.csv gs://ustraakr-proclogs/$bid/$ldt/ip.csv
gsutil cp $DPATH/$ldt/ip.txt gs://ustraakr-proclogs/$bid/$ldt/ip.txt
gsutil cp $DPATH/$ldt/csp.csv gs://ustraakr-proclogs/$bid/$ldt/csp.csv
#-----------------------------------------------------------------------------------------------------------

# upload sid-ip for view to bigquery

#bq load --allow_jagged_rows --ignore_unknown_values --source_format=CSV  poetic-primer-844:anlog."$bid"_csp gs://ustraakr-proclogs/$bid/$ldt/csp.csv

# delete these files from local

sudo rm $DPATH/$ldt/psip.csv
sudo rm $DPATH/$ldt/sip.csv
sudo rm $DPATH/$ldt/cs-parent-psip.csv
sudo rm $DPATH/$ldt/ip.csv
sudo rm $DPATH/$ldt/ip.txt
sudo rm $DPATH/$ldt/csp.csv

#-----------------------------------------------------------------------------------------------------------


