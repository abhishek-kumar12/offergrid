#!/bin/bash 

dt=$( date -d "yesterday 13:00 " '+%d-%m-%Y' )
OPATH="/mnt/disks/traakr/us.bm/VTAG/7388/"
DPATH="/mnt/disks/traakr/us.bm/VTAG/7388/"$dt"/"
# get total suspected ips
<$OPATH/n413_botman_ipcidr_$dt.txt wc -l > /tmp/total_$dt.sips
sudo mv /tmp/total_$dt.sips $OPATH
sleep 10 
totalsips=sudo cat $OPATH/total_$dt.sips
sleep 10 
sudo /home/traakr/us.bm/shootmail.sh "deeps@botman.ninja" "IP BlackList Uploaded for $dt" "Dear Deeps,\n\nThe latest IP blacklist has been uploaded to adKernel.\n\nCheers\n\nYour own team at Botman" 
sudo /home/traakr/us.bm/shootmail.sh "raj@botman.ninja" "IP BlackList Uploaded for $dt" "Dear Raja,\n\nThe latest IP blacklist with $totalsips has been uploaded to adKernel.\n\nCheers\n\nYour own team at Botman" 
sudo /home/traakr/us.bm/shootmail.sh "hardik@botman.ninja" "IP BlackList Uploaded for $dt" "Dear Hardik,\n\nThe latest IP blacklist with $totalsips has been uploaded to adKernel.\n\nCheers\n\nYour own team at Botman" 
sudo /home/traakr/us.bm/shootmail.sh "abhishek.kumar@offergrid.com" "IP BlackList Uploaded for $dt" "Dear AK,\n\nThe latest IP blacklist with $totalsips has been uploaded to adKernel.\n\nCheers\n\nYour own team at Botman" 
sudo /home/traakr/us.bm/shootmail.sh "jc@yeesshh.com" "IP BlackList Uploaded for $dt" "Dear JC,\n\nThe latest IP blacklist with $totalsips has been uploaded to adKernel.\n\nCheers\n\nYour own team at Botman" 
sudo /home/traakr/us.bm/shootmail.sh "luis@yeesshh.com" "IP BlackList Uploaded for $dt" "Dear JC,\n\nThe latest IP blacklist with $totalsips has been uploaded to adKernel.\n\nCheers\n\nYour own team at Botman" 
sudo /home/traakr/us.bm/shootmail.sh "emile@yeesshh.com" "IP BlackList Uploaded for $dt" "Dear JC,\n\nThe latest IP blacklist with $totalsips has been uploaded to adKernel.\n\nCheers\n\nYour own team at Botman" 
