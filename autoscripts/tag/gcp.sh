bid=$1
dt=$2
DPATH=/mnt/disks/traakr/a.us.bm/VTAG/$bid
if ([ ! -f $DPATH/$dt/ip.csv ]); then
sudo gsutil cp gs://ustraakr-proclogs/$bid/$dt/ip.csv $DPATH/$dt/ip.csv
fi

if ([ ! -f $DPATH/$dt/ip.txt ]); then
sudo gsutil cp gs://ustraakr-proclogs/$bid/$dt/ip.txt $DPATH/$dt/ip.txt
fi

if ([ ! -f $DPATH/$dt/csp.csv ]); then
sudo gsutil cp gs://ustraakr-proclogs/$bid/$dt/csp.csv $DPATH/$dt/csp.csv
fi

if ([ ! -f $DPATH/$dt/sip.csv ]); then
sudo gsutil cp gs://ustraakr-proclogs/$bid/$dt/sip.csv $DPATH/$dt/sip.csv
fi

if ([ ! -f $DPATH/$dt/sip.txt ]); then
sudo gsutil cp gs://ustraakr-proclogs/$bid/$dt/sip.txt $DPATH/$dt/sip.txt
fi

