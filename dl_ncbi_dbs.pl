#!/usr/bin/env perl
use Digest::MD5;
use Archive::Extract;
use strict;
use warnings;
use Net::FTP;
use Getopt::Long;
use Pod::Usage;
use File::stat;
use File::Copy;

#FTP server settings
#####################
use constant VERSION => 1.2;
use constant NCBI_FTP => "ftp.ncbi.nlm.nih.gov";
use constant BLAST_DB_DIR => "/blast/db/v4/";
use constant USER => "anonymous";
use constant PASSWORD => "anonymous";
use constant DEBUG => 0;
$Archive::Extract::PREFER_BIN = 1;

#Email address to send notifications to
my $notifyEmail = "dslater\@igb.illinois.edu";
my $fromEmail = "biocluster\@igb.illinois.edu";

#Where to download the compressed files
my $compressedDownloads = "/home/a-m/datamover/no_backup/TEMP_NCBI_DBS";

#Where to uncompress data to
my $uncompressedDownloads = "/home/a-m/datamover/no_backup/TEMP_NCBI_DBS_EXTRACTED";

#The parent directory where we store all the databases by download date
my $blastDbsDir = "/private_stores/mirror/ncbi-blastdb";


# Process command line options for FTP
######################################
my $opt_verbose = 1;
my $opt_quiet = 0;
my $opt_force_download = 0;
my $opt_help = 0;
my $opt_passive = 0;
my $opt_timeout = 600;
my $opt_showall = 0;

my $try=0;
my $ftp;
my $maxTries=4;

#Create a directory name with todays date
my $dateDir = local_yyyymmdd();
my $dateDirPart = "PART_".$dateDir;

#Directories where where we store the downloaded databases for the current download session
my $extractDestination=$uncompressedDownloads."/".$dateDirPart;
my $finalDirName =$blastDbsDir."/".$dateDir;

#Create the daily directory if it doesnt exist
unless(-d $extractDestination){
	mkdir $extractDestination or die;
}

print $compressedDownloads;

my $errorDetails="";
my $fileStatus=1;
my @extractedDbFiles;
my $file;
my $count;
#For some reason the md5 never matches on this database so just ignore it
my @nodMD5Exceptions = ("vector.tar.gz");

chdir($compressedDownloads);

#Get a list of files available to download form NCBI FTP
my @filesToDownload = get_files_to_download();
foreach $file (@filesToDownload)
{
	$try=0;
	if($fileStatus!=0)
	{
		do {
			$fileStatus=1;

			download($file);
			if(open(FILE,$file."\.md5") or is_exception($file))
			{
    				my $md5line = <FILE>;
				close(FILE);
       				my $ftpMD5;
       				my $fileName;

       			        ($ftpMD5,$fileName) = split(/ +/,$md5line);
       				my $actualMD5=md5sum($file);

				#Compare MD5 checksums of file to NCBI available checksum
			        if($actualMD5 eq  $ftpMD5 or is_exception($file))
				{
					$fileStatus=1;
					print "\n$file passed MD5 Check (".$actualMD5.")";

					#Extract archive files
      			        	my $archiveExtract=Archive::Extract->new( archive => $file );
       	       			  	my $status=$archiveExtract->extract( to => $extractDestination );
					print "\nExtracting $file ...";
             	  	 		if($archiveExtract->error(1) ne "")
      	       			   	{
						$fileStatus=0;
						unlink($file);
						$errorDetails=$errorDetails."Error Extracting archive";
        	       	 		}else{
						$fileStatus=1;
						print "\n$file Extracted";
					}
	       	         		undef $archiveExtract;
				}else{
					$fileStatus=0;
                                        unlink($file);
					$errorDetails=$errorDetails."Error matching MD5";
				}
			}else{
				unlink($file);
				$fileStatus=0;
				print "Error opening MD5 file";
			}
			$try=$try+1;		
		}while($fileStatus == 0 and $try < $maxTries);
	}
}	

if($fileStatus==0)
{
	print "Send email of failure to download correctly";
	sendEmail($notifyEmail,$fromEmail,"Error Updating Blast DBs on biotransfer","Tries: ".$try." Success Code: ".$fileStatus."\nError Details:".$errorDetails);	
}else{
	#since extraction was successful we need to rename the folder to not include the PART_ string
	move("$extractDestination","$finalDirName");

	#Remote old symbolic link
	system("rm -f ".$blastDbsDir."/latest");

	#Point the latest symoblic link directory to this new databases folder
	system("ln -s ".$finalDirName." ".$blastDbsDir."/latest");

	#latest file so programs can tell which folder is the latest
	#open(LATESTFILE,">".$blastDbsDir."/latest.txt");
	#print LATESTFILE $dateDir;
	#close(LATESTFILE);

	#Send e-mail to notify admin of successful update
        print "Send email of success";
        sendEmail($notifyEmail,$fromEmail,"Success Updating Blast DBs biocluster","Tries: ".$try." Success Code: ".$fileStatus);
}

#Subroutines
###############################################

#Check File MD5
sub md5sum{
  my $file = shift;
  my $digest = "";
  eval{
    open(FILE, $file) or die "Can't find file $file\n";
    my $ctx = Digest::MD5->new;
    $ctx->addfile(*FILE);
    $digest = $ctx->hexdigest;
    close(FILE);
  };
  if($@){
    print $@;
    return "";
  }else{
    return $digest;
  }
}

#simple Email Function
# ($to, $from, $subject, $message)
sub sendEmail
{
        my $to = shift;
        my $from = shift;
        my $subject = shift;
        my $message = shift;
        my $sendmail = '/usr/sbin/sendmail -t';

        open(MAIL, "|$sendmail") or die "Cannot open $sendmail: $!";;
        print MAIL "From: $from\n";
        print MAIL "To: $to\n";
        print MAIL "Subject: $subject\n\n";
        print MAIL "$message\n";
        close(MAIL);

}

# Connects to NCBI ftp server
sub connect_to_ftp
{
    my %ftp_opts;
    $ftp_opts{'Passive'} = 1 if $opt_passive;
    $ftp_opts{'Timeout'} = $opt_timeout if ($opt_timeout >= 0);
    my $ftp = Net::FTP->new(NCBI_FTP, %ftp_opts)
        or die "Failed to connect to " . NCBI_FTP . ": $!\n";
    $ftp->login(USER, PASSWORD)
        or die "Failed to login to " . NCBI_FTP . ": $!\n";
    $ftp->cwd(BLAST_DB_DIR);
    $ftp->binary();
    print STDERR "\nConnected to NCBI";
    return $ftp;
}

# Obtains the list of files to download
sub get_files_to_download
{
    $ftp = &connect_to_ftp();
    my @blast_db_files = $ftp->ls();
    my @retval = ();

    if (DEBUG) {
        print STDERR "DEBUG: Found the following files on ftp site:\n";
        print STDERR "DEBUG: $_\n" for (@blast_db_files);
    }

   for my $file (@blast_db_files) {
       next unless ($file =~ /\.tar\.gz$/);
       		push @retval, $file;
    }
    $ftp->quit;
    return @retval;
}

# Download the requestes files only if they are missing or if they are newer in
# the FTP site.
sub download
{
    my $dlFile = shift;
    $ftp = &connect_to_ftp();
    if (not -f $dlFile or ((stat($dlFile))->mtime < $ftp->mdtm($dlFile))) {
    	print STDERR "Downloading $dlFile...\n ";
	$ftp->get($dlFile."\.md5");
      	$ftp->get($dlFile);
    } else {
    	print STDERR "\n$dlFile is up to date.";
    }
    $ftp->quit;
}

#check if a database is in the MD5 exception lists
#some places dont update the md5s for some of the databases and they fail all the time
sub is_exception
{
	my $fileName = shift;
	
	foreach(@nodMD5Exceptions)
	{
		if( $fileName eq $_ )
		{
			return 1;
		}
	}
	return 0;
}

#Generate a directory name from todays date
sub local_yyyymmdd {
  my $time = shift || time();
  my ($year, $month, $mday) = (localtime($time))[5,4,3];
  return 10_000*($year + 1900) + 100*($month + 1) + $mday;
}

