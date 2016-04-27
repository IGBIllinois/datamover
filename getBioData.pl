#!/usr/bin/perl
###########################################################################
# Program Name getBioData.pl
# Download files from remote sites when newer files are posted.
# How to run:
#   perl getBioData.pl -f /home/a-m/datamover/no_backup/download/biofilelist.txt
# 
# biofilelist.tx is a file list to be updated. It is located at 
# /home/a-m/datamover/no_backup/download directory. A log file will be generated
# at the same directory.
###########################################################################
use Getopt::Std;
use strict;
use Cwd;
use Net::FTP;
use File::stat;
use Time::localtime;
#
# Following variables are needed

#my $workDir="/home/a-m/ligong/no_backup/download/interpro"; #working directory
my $workDir="/home/a-m/datamover/no_backup/download/"; 
chdir($workDir);
my $logFile = $workDir . "\/biodownload.log";
#print "log file: $logFile\n";
open LOG, ">>$logFile";
my $runTime = &getTimeStamp;
print LOG "getBioData starts: $runTime\n";

my %opts;
getopts('f:',\%opts);
if(!defined $opts{'f'}) { # Check for arguments
        print LOG "Need biodownload list file.\n";
        die("File list not found.\n");
}
my $infile = $opts{'f'}; 

# array to hold files to be downloaded.
my @downloadList = &getDownloadList($infile);
foreach my $file (@downloadList){
   my ($fileName, $localDir, $remoteDir, $compressed, $host, $user, $password) = split /,/, $file;
   my $lFileTime = &getModifiedTime($fileName, $localDir);
   my $flag = &getFile($fileName, $localDir, $remoteDir, $compressed, $lFileTime, $host, $user, $password);
   if($flag ==1){
      print LOG "download problem for $fileName\n";
   }
}

my $rumTime =&getTimeStamp;
print LOG "getBioData ends: $runTime\n";

###########################################################################
#functions
###########################################################################

#########################################################
#getFile
#Download a file from a remote site if the file is newer than the 
#local file. .
#########################################################
sub getFile{
   my($fileName, $local, $remote, $fileType, $lTime, $hostName, $userName, $passwd) = @_;
   my $downloadFile = $fileName;
   my $errorFlag = 0;
   my $ftp = Net::FTP->new($hostName) or $errorFlag=1;
   if($errorFlag){
      print LOG "Can't connect to $hostName\n";
      return $errorFlag=1;
   }
   $ftp->login($userName, $passwd) or $errorFlag=1;
   if($errorFlag){
      print LOG "can't log $userName in \n";
      return $errorFlag=1;
   }
   $ftp->binary();
   $ftp->cwd($remote) or $errorFlag=1;
   if($errorFlag){
      print LOG "Can't cwd to $remote\n";
      return $errorFlag=1;
   }
   if($fileType ne "n"){
     $downloadFile = $fileName . ".$fileType";
   }
   #get remote file modified time
   my $remoteFileTime = $ftp->mdtm($downloadFile) or return $errorFlag=1;   
   if($remoteFileTime >= $lTime){
      my $cmd;
      print "downloading file: $downloadFile\n"; 
      $ftp->get($downloadFile) or $errorFlag=1;
      if($errorFlag){
         print LOG "Can't get $downloadFile\n";
         return $errorFlag=1;
      }
      if($fileType eq "gz"){
        $cmd = "gunzip $downloadFile";
    #    print "uncompress file: $cmd\n";
        system ($cmd);
      }
      $cmd = "mv $fileName $local$fileName";
    #  print "move file: $cmd\n";
      system($cmd);
      $cmd ="chmod 775 $local$fileName";
    #  print "change file permission: $cmd\n";
      system($cmd);
      $cmd ="chgrp hpcbio $local$fileName";
   #   print "change file group: $cmd\n";
      system($cmd);     
      print LOG "$downloadFile has been updated\n"; 
   }
   else{
      print LOG "Do not need to update $downloadFile\n"; 
   }
   $ftp->close();
   return $errorFlag; 
}
############################################################
#Get local file modofied time
############################################################
sub getModifiedTime{
  my($fileName, $location)=@_;
  my $file=$location . $fileName;
 # my $fileTime=ctime(stat($file)->mtime());
  my $fileTime=(stat($file)->mtime());
  return $fileTime;
}
###########################################################
#getDownloadList
#
###########################################################
sub getDownloadList{
    my ($file) =@_;
    open (inputFile, $file) or die("Error: cannot open file: $file\n");
    my $line;
    my @fList;
    while ($line = <inputFile>){
       chomp($line);
       push(@fList, $line);
    }
    close(inputFile);
    return @fList;
}

#########################################################
# get system time and format the time string.
#########################################################
sub getTimeStamp{
   #my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
   #my $tmp = ($year+1900).($mon+1).$mday.":$hour:$min:$sec";
   my $tmp= ctime(time);
   return $tmp;
}



1;
