<?php
set_time_limit(0);
session_start();
/**********************************************************
This script will read the csv and create a VTAG structure ,
7388 map 
date_crid_plid.log structure

@author:Deeps (deeps@botman.ninja)
**********************************************************/

	include "/home/traakr/us.bm/application/models/TLog.php";
	$bizid 					=  $_REQUEST['bizid'];
	$homeBase 				=  '/home/traakr/us.bm/';
	$vtagBase 				=  '/mnt/disks/traakr/us.bm/VTAG/'.$bizid;
	$dblog 					=  new TLog();
	$enabledSourceFile 			=  $homeBase.'enabledSourceFile.txt';
	$udate=  $_REQUEST['userdate'];
	if(empty($udate))
	{
		$udate=date('d-m-Y', strtotime("-1 days"));
	} else
	{
		$udate=  $_REQUEST['userdate'];
	}

    $enabledSources 			=  file($enabledSourceFile, FILE_IGNORE_NEW_LINES);
    $lastMappedFile 			=  $homeBase.$udate.$bizid.'-lastMapLog.txt';

    $aday						=  $_REQUEST['aday'];
  
    $trap						=  $_REQUEST['trap'];
    $day						=  date('d-m-Y', strtotime($udate));
    $mapData = array();

   
    if (!file_exists($vtagBase)) {
           if (!mkdir($vtagBase, 0755)) {
                die("\nFailed to create filepath_biz...");
                }
     }

     $vtagDay  = $vtagBase.'/'.$day;

		if (!file_exists($vtagDay)) {
			if (!mkdir($vtagDay, 0755)) {
				die("\nFailed to create vtagDay...");
					 }
				}

	 $vtagTrap  = $vtagDay.'/'.$trap;

		if (!file_exists($vtagTrap)) {
			if (!mkdir($vtagTrap, 0755)) {
				die("\nFailed to create vtagTrap...");
					 }
				}
 
  // Open the file and start mapping
  // Referecne

  //{"server":{"HTTP_HOST":"us.bm.traakr.com","HTTP_CONNECTION":"keep-alive","HTTP_ORIGIN":"http://app.bettercampaign.in","HTTP_USER_AGENT":
  //"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36","HTTP_ACCEPT":
  //"*/*","HTTP_REFERER":"http://app.bettercampaign.in/adk.html","HTTP_ACCEPT_ENCODING":"gzip, deflate","HTTP_ACCEPT_LANGUAGE":"en-US,en;q=0
  //.9,hi;q=0.8","HTTP_COOKIE":"PHPSESSID=5srorv47e5nmnmdj8feflpmvu1","PATH":"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
  //"SERVER_SIGNATURE":"<address>Apache/2.4.7 (Ubuntu) Server at us.bm.traakr.com Port 80</address>\n","SERVER_SOFTWARE":"Apache/2.4.7 (Ubun
  //tu)","SERVER_NAME":"us.bm.traakr.com","SERVER_ADDR":"10.240.0.7","SERVER_PORT":"80","REMOTE_ADDR":"106.51.110.144","DOCUMENT_ROOT":"/hom
  //e/traakr/us.bm","REQUEST_SCHEME":"http","CONTEXT_PREFIX":"","CONTEXT_DOCUMENT_ROOT":"/home/traakr/us.bm","SERVER_ADMIN":"og@us.bm.traakr
  //.com","SCRIPT_FILENAME":"/home/traakr/us.bm/VTAG/index.php","REMOTE_PORT":"28839","GATEWAY_INTERFACE":"CGI/1.1","SERVER_PROTOCOL":"HTTP/
  //1.1","REQUEST_METHOD":"GET","QUERY_STRING":"_bcbz=7388&oref=http://app.bettercampaign.in/adk.html&p={%22iw%22:1280,%22ih%22:388,%22ow%22
  //:1280,%22oh%22:736,%22sl%22:0,%22st%22:22,%22wl%22:0,%22sh%22:800,%22sw%22:1280,%22scd%22:24,%22no%22:true,%22ce%22:true,%22oref%22:%22h
  //ttp://app.bettercampaign.in/adk.html%22,%22ifp%22:0,%22hl%22:2,%22s%22:0,%22bcbz%22:7388}","REQUEST_URI":"/VTAG/index.php?_bcbz=7388&ore
  //f=http://app.bettercampaign.in/adk.html&p={%22iw%22:1280,%22ih%22:388,%22ow%22:1280,%22oh%22:736,%22sl%22:0,%22st%22:22,%22wl%22:0,%22sh
  //%22:800,%22sw%22:1280,%22scd%22:24,%22no%22:true,%22ce%22:true,%22oref%22:%22http://app.bettercampaign.in/adk.html%22,%22ifp%22:0,%22hl%
  //22:2,%22s%22:0,%22bcbz%22:7388}","SCRIPT_NAME":"/VTAG/index.php","PHP_SELF":"/VTAG/index.php","REQUEST_TIME_FLOAT":1518026937.96,"REQUES
  //T_TIME":1518026937},"sid":"5srorv47e5nmnmdj8feflpmvu1","pid":"7388","systs":1518026937}

  // make an array of all the pids enabled for analysis


	if($aday)
	{
		
		$userDate 				=  date("YmdHis", strtotime($udate));
		
  		$fromWhereToPickupCSV 	=  '/mnt/disks/backup1/CLICKLOGS/'.$bizid.'/'.'mnt/disks/traakr/asia.bm/VTAG/'.$bizid.'/';


		$fw = fopen($lastMappedFile, 'w');
		fwrite($fw, $userDate);
		fclose($fw);
 
			  // increment the dates
			  $fr = fopen($lastMappedFile, 'r');
			  $lastEndDateFromDB = fgets($fr);
			  fclose($fr);
			  
		$fromDate 			=  date("d-m-Y", strtotime($lastEndDateFromDB) );
		$CSVFileName 			=  $fromWhereToPickupCSV.'/'.$fromDate.'.log';

 			  $row=0;
			  $startrow = 0; // pick up chunks of 100
			  $dblog->logkaro('start row is '.$startrow);

				$handle = fopen($CSVFileName, "r");
				if ($handle) {

			    	while (($line = fgets($handle)) !== false) {
			       
	        			$data = json_decode($line);
				       if($data->data->server->HTTP_USER_AGENT == '')
					{
						continue;
					}	 	
				        		$ua 		= $data->data->server->HTTP_USER_AGENT;
				        		$ip         = $data->data->server->REMOTE_ADDR;
				        		$ref        = $data->data->server->HTTP_REFERER;
				        		$qs 		= $data->data->server->QUERY_STRING;
				        		$ts  		= $data->data->server->REQUEST_TIME;
				        		$rw  		= $data->data->server->HTTP_X_REQUESTED_WITH;
				        		$sid        = $data->data->sid;

				//echo $row++;			        	 	
				// split qa
				$b=parse_url($qs); 
				print('<pre>');
				//var_dump($b);	 exit;
				print('</pre>');
				$p=parse_str($b['path'],$p1);
				print('<pre>');
				//var_dump($p1);	
				print('</pre>');
				$base_url=$p1['oref'];
				$b1=explode('oref',$b['query']); 
				// this will split the utms inthe 0th index;
				$b2=explode('&',$b1[0]);
				print('<pre>');
				//var_dump($b2);
				print('</pre>');
				$len=count($b2);
				unset($b2[$len-1]);

				$b3=implode('&',$b2);
				$b4=parse_str($b3,$up);
				print('<pre>');
				//var_dump($up);
				print('</pre>');
			
				$utms = ($p1['cid']) ? $p1['cid'] : 'NA';
				$utmm = ($p1['agid']) ? $p1['agid']: 'NA';
				$utmcon = ($p1['crid']) ? $p1['crid']: 'NA';
				$utmterm = ($up['utm_term']) ? $up['utm_term']: 'NA';
				$utmcamp = ($up['utm_campaign']) ? $up['utm_campaign']: 'NA';
				$rwa= isset($rw) ? $rw : 'NA';
				$qsa= isset($b['path']) ? $b['path'] : 'NA';
				 date_default_timezone_set('Asia/Kolkata');
                                // convert epoch time to oooostandard format
                                $dt = new DateTime("@$ts");  // convert UNIX timestamp to PHP DateTime
                                //var_dump($dt);
                                $ts = $dt->format('Y-m-d H:i:s');

			 	$csv_ipdata=$ip.'|'.$utms.'|'.$utmm.'|'.$utmcon.'|'.$utmterm.'|'.$utmcamp.'|'.$base_url.'|'.$sid.'|'.$ts.'|'.$rwa.'|'.$qsa;
			 	$csv_uadata=$ua.'|'.$utms.'|'.$utmm.'|'.$utmcon.'|'.$utmterm.'|'.$utmcamp.'|'.$base_url.'|'.$sid.'|'.$ts;
			 	$csv_refdata=$ref.'|'.$utms.'|'.$utmm.'|'.$utmcon.'|'.$utmterm.'|'.$utmcamp.'|'.$base_url.'|'.$sid.'|'.$ts;
                                $csv_csdata=$ip.'|'.$ts.'|'.$sid.'|'.$ua.'|'.$rwa.'|'.$qsa;
                                $csv_rwdata=$ip.'|'.$ts.'|'.$sid.'|'.$utms.'|'.$utmm.'|'.$rwa.'|'.$ua;
				$csv_ifpdata = $ip.'|'.$ts.'|'.$sid.'|'.$lp.'|'.$ifp;
                                $refdata=$ip.'|'.$ref;
                                $uadata=$ip.'|'.$ua;
                                $ipdata = $ip;
				$csv_vwdata = $p1['_bcbz'].'|'.$rw.'|'.$ts.'|'.$ip.'|'.$sid.'|'.$ua.'|'.$p1['cor'].'|'.$p1['cid'].'|'.$p1['agid'].'|'.$p1['crid'].'|'.$p1['x'].'|'.$p1['y'].'|'.$p1['ih'].'|'.$p1['iw'].'|'.$p1['oh'].'|'.$p1['ow'].'|'.$p1['ifp'].'|'.$p1['hl'].'|'.$p1['vis'].'|'.$p1['purl'];        	 	 
				        		
				$feedfolder  = $vtagDay;
							if (!file_exists($feedfolder)) {
									if (!mkdir($feedfolder, 0755)) {
										die("\nFailed to create feedfolder...");
											 }
										}
   														$ipfile = $feedfolder.'/ip.txt';
                                                        $uafile = $feedfolder.'/ua.txt';
                                                        $reffile = $feedfolder.'/ref.txt';

                                                        $csv_ipfile = $feedfolder.'/ip.csv';
                                                        $csv_reffile = $feedfolder.'/ref.csv';
                                                        $csv_uafile = $feedfolder.'/ua.csv';
                                                        $csv_rwfile = $feedfolder.'/rw.csv';
                                                        $csv_csfile = $feedfolder.'/csp.csv';
                                                        $csv_ifpfile = $feedfolder.'/ifp.csv';
                                                        $csv_vwfile = $feedfolder.'/vw.csv';


                                                        $fi =  fopen($ipfile, 'a');
                                                        fwrite($fi, $ipdata);
                                                        fwrite($fi, "\n");

                                                        $fid =  fopen($csv_ipfile, 'a');
                                                        fwrite($fid, $csv_ipdata);
                                                        fwrite($fid, "\n");

                                                        $fcs =  fopen($csv_csfile, 'a');
                                                        fwrite($fcs, $csv_csdata);
                                                        fwrite($fcs, "\n");

                                                        $fvw =  fopen($csv_vwfile, 'a');
                                                        fwrite($fvw, $csv_vwdata);
                                                        fwrite($fvw, "\n");
                                                        
							//$frw =  fopen($csv_rwfile, 'a');
                                                        //fwrite($frw, $csv_rwdata);
                                                        //fwrite($frw, "\n");
							
/*
							$fua =  fopen($uafile, 'a');
                                                        fwrite($fua, $uadata);
                                                        fwrite($fua, "\n");

                                                        $fref =  fopen($reffile, 'a');
                                                        fwrite($fref, $refdata);
                                                        fwrite($fref, "\n");

                                                        $frf =  fopen($csv_reffile, 'a');
                                                        fwrite($frf, $csv_refdata);
                                                        fwrite($frf, "\n");

                                                        $fsid =  fopen($csv_uafile, 'a');
                                                        fwrite($fsid, $csv_uadata);
                                                        fwrite($fsid, "\n");
                                                        $fifp =  fopen($csv_ifpfile, 'a');
                                                        fwrite($fifp, $csv_ifpdata);
                                                        fwrite($fifp, "\n");
				         
 */				        	 
				     
			     
		
			    } // end of while 
			   
			} // end of file open if 

		
	}	
	 
    
?>
