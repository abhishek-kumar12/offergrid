<?php
set_time_limit(0);
/**********************************************************
This script will run every half hour through the cron , 
@download zip
@unzip
@move
@convert and
@audit in the DB

@author:Deeps (deeps@botman.ninja)
Two configuration files
// last record 
// audit of all files read
**********************************************************/

	// adkernel timezone
	date_default_timezone_set('America/Los_Angeles');
	$homeBase = '/home/traakr/us.bm/';
	
	include "/home/traakr/us.bm/application/models/TLog.php";

	$dblog = new TLog();

	$bizid 	= $_REQUEST['bizid'];
	$aday	= $_REQUEST['aday'];
	$refresh = $_REQUEST['refresh'];

	// check if the synclog is presensynsync
	// dont do it again

	if($aday)
	{
		//$udate = $_REQUEST['userdate'];
		// get current date
		$udate=date('d-m-Y', strtotime("-1 days"));
		$lastRecordFile = $homeBase.$udate.'-lastClickLog.txt';
		$userDate =  date("YmdHis", strtotime($udate));
	        if($refresh)
	{
			$fw = fopen($lastRecordFile, 'w');
			fwrite($fw, $userDate);
			fclose($fw);
	}
		for($d=0;$d<=48;$d++)
		{
			
			$fr = fopen($lastRecordFile, 'r');
			$lastEndDateFromDB = fgets($fr);
			fclose($fr);

			$fromDate =  date("YmdHis", strtotime($lastEndDateFromDB) );
		 	
			// to date (last end date + 30 minutes), has to be accurate to the last second
			$toDate =  date("YmdHis", strtotime($fromDate . "+30 minutes"));
			
			// client adkernel id
			$client_adkernel_id = 'n413';
			// botman id
			$botman_adkernel_id = 'botman';
			
			// from where to download file path
			$fromWhereToDownloadFile = 'http://statsfiles.wowcon.net/';

			// where to move file path

			$localSourcePath = getcwd();
			$whereToMoveFileBase =  '/mnt/disks/backup1/CLICKLOGS';
		 
		 	// final file name
		 	$downloadFileName = 'clicks-'.$client_adkernel_id.'-'.$botman_adkernel_id.'-'.$fromDate.'-'.$toDate.'.csv.zip';
		 	$moveFileName = 'clicks-'.$client_adkernel_id.'-'.$botman_adkernel_id.'-'.$fromDate.'-'.$toDate.'.csv';

		 	// download Path
		 	$downloadPath = $fromWhereToDownloadFile.$downloadFileName;
			
		 	// create folder if not there

		 	$whereToMoveFile= $whereToMoveFileBase.'/'.$bizid.'/'.$udate;

		        if (!file_exists($whereToMoveFile)) {
		                if (!mkdir($whereToMoveFile, 0755)) {
		                die('\nFailed to create filepath_biz...');
		                }
		     }

//		    $whereToArchiveFile = '/mnt/disks/backup1/archive';

		 	// Download Process
		    $addx = 'wget '.$downloadPath;
		    exec($addx, $outputx, $return_varx);
//		    $dblog->logarray($outputx);
		    if($return_varx > 0)
		    {
		    	$dblog->logkaro('wget returned error..');
		    }

		    // Unzip
		    $addy = "unzip " . $downloadFileName;
		    exec($addy, $outputy, $return_vary);
//		    $dblog->logarray($outputy);

		 	// move file
		  $addz = "mv ".$moveFileName." ".$whereToMoveFile;
		    exec($addz, $outputz, $return_varz);
//		    $dblog->logarray($outputz);

		    // move zip file to archive
//		 	$adda = "mv ".$downloadFileName." ".$whereToArchiveFile;
//		    exec($adda, $outputa, $return_vara);
//		    $dblog->logarray($outputa);
		    // rewrite the lastRecordFile with final value
		    $fw = fopen($lastRecordFile, 'w');
			fwrite($fw, $toDate);
			fclose($fw);
  }
}
 
?>
