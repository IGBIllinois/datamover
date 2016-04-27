#!/usr/bin/perl
##############################################################################################################
#Proram Name:getUniprotFasta.pl
#Purposes:Download uniprot database files from ftp.uniprot.org.
#Paremeters: -f uniproFileList.txt
#uniprotFileList.txt file format:
# ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
# ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_trembl.fasta.gz
# ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping.dat.gz
# ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/uniref/uniref100/uniref100.fasta.gz
# ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/uniref/uniref90/uniref90.fasta.gz
# ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/uniref/uniref50/uniref50.fasta.gz
#
# uniprotFileList.txt is loacated in donwload directory.
#############################################################################################################

use Getopt::Std;
use strict;
use Cwd;
#use DateTime;

# find download direcotries:
my $currentReleaseDir = "current_release";
#my $downloadDir="/home/a-m/ligong/no_backup/download/uniprot/";
my $downloadDir="/home/a-m/datamover/no_backup/download/uniprot/";
my $currentReleaseDir = $downloadDir . "current_release\/";
chdir($currentReleaseDir);
my $workingDir = getcwd;
#print "Current Directory: $workingDir\n";

my $blastDir = $currentReleaseDir . "blast\/";
my $blastPlusDir =  $currentReleaseDir . "blast+\/";
my $fastaDir =  $currentReleaseDir . "fasta\/";

#################################################################
# Check file directories.
#################################################################
  unless(-d $blastDir){ 
      my $cmd = "mkdir $blastDir";
      system ("mkdir $blastDir");
  }
  unless(-d $blastPlusDir){
      system ("mkdir $blastPlusDir");
   }
   unless(-d $fastaDir){
      system ("mkdir $fastaDir");
   }
   unless(-d $currentReleaseDir){
      system ("mkdir $currentReleaseDir");
   }

# old release note
my $oldReleaseNote = "/home/mirrors/uniprot/current_release/relnotes.txt";
my $logFile = $downloadDir . "uniprotDownload.log";
# local mirrored directory
my $mirrorDir = "/home/mirrors/uniprot/";
my $mirrorCurrentReleaseDir =  $mirrorDir . "current_release\/";

open LOG, ">>$logFile";
my $tStamp = &getTimeStamp;
print LOG "$tStamp: Start updating uniprot files\n";
my $prog = "wget ";
my %opts;

getopts('f:',\%opts);
if(!defined $opts{'f'}) { # Check for arguments
        print LOG "Need uniprot file list.\n";
        die("File list not found.\n");
}
#clear old files.
&clearFiles;


#check release
my $newReleaseNote = &getReleaseNote;
my $oldRelease = &getRelease($oldReleaseNote);
my $newRelease = &getRelease($newReleaseNote);
#print "old release: $oldRelease\n";
#print "new release: $newRelease\n";

if($oldRelease eq $newRelease){
  print LOG "No need update.\n";
  $tStamp = &getTimeStamp;
  print LOG "$tStamp: Exit program.\n";
  exit;
}
my $infile = $downloadDir . "$opts{'f'}"; 
#open donwload list file
open (inputFile, $infile) or die("Error: cannot open file $infile\n");
my $line;
my %hFile;
my @fList;
while ( $line = <inputFile>){
   chomp($line);
   push(@fList, $line);
   my @temp = split /\//, $line;
   my $fName = pop @temp;
 #  print "Fname: $fName\n";
   $hFile{$line} = $fName;
}
#while (my ($key, $value) = each(%hFile)){
#   print "$key $value\n";
#}
###########################################
#download files
#uncompress files
#build blast database files
###########################################
my @child;
my $cmd;
my $error=0;
foreach my $file (@fList){
#   chomp $proj;
#print "File Name: $file\n";
   my $pid = fork();
   if($pid){#parent
      push(@child, $pid);
   }
   elsif($pid == 0){ #child
      $cmd = $prog . $file;
      print LOG "download file\ncmd: $cmd\n";
      #download file.
      my $return = system($cmd);
      if($return !=0){
        print LOG "Download $file failed.\n";
        die;
      } 

      #sleep 5;
      exit(0); 
   }
   else{
      die "couldn't fork :!\n";
   }
#   print "Last file\n";
}
foreach(@child){
   waitpid($_, 0);
}

&copyFiles;

$tStamp = &getTimeStamp;
print LOG "$tStamp: Finshed updating uniprot files.\n";
##################################################################################
#Functions
##################################################################################
############################################
#get release note file from ftp site
############################################
sub getReleaseNote{
   my $releaseFile = $currentReleaseDir . "relnotes.txt";
   my $return = system("wget -O $releaseFile ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/relnotes.txt");
   if($return !=0){
      print LOG "release file not fond.\n";
      die;
   } 
   return $releaseFile;
}
##############################################
#get release number from a release note file
##############################################
sub getRelease{
   my($releaseFile)=@_;
   my $release;
   open (rl, $releaseFile) or die("Error: cannot open file $releaseFile\n");
   while ( $line = <rl>){
      chomp($line);
      if ($line =~ /UniProt Release/){
          my @temp = split / /, $line;
          $release = pop @temp;
          return $release;
      }     
   }
   return $release;
}
#########################################################
# get system time and format the time string.
#########################################################
sub getTimeStamp{
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
   my $tmp = ($year+1900).($mon+1).$mday.":$hour:$min:$sec";
   return $tmp;
}
######################################################################
# remove all the files in the directory before downloading new files.
######################################################################
sub clearFiles{
   system("rm -f $currentReleaseDir\*.gz");
   system("rm -f $blastDir\*.*");
   system("rm -f $blastPlusDir\*.*");
   system("rm -f $fastaDir\*.*");
}
####################################################
#move current release to an old release
#copy new dowloaded release to current release 
####################################################
sub copyFiles{
	my $fullMirrorCurrentReleaseDir = $mirrorDir . "release-" . $newRelease;
	$cmd = "mkdir $fullMirrorCurrentReleaseDir";
	unless(-d $fullMirrorCurrentReleaseDir){
   		system ($cmd);
	}
   
   $cmd = "mv -f $currentReleaseDir\* $fullMirrorCurrentReleaseDir";
   #print "move downloaded file to destination directory: $cmd\n";
   system($cmd);
   $cmd = "chmod -Rf 775 $fullMirrorCurrentReleaseDir";
   system($cmd);
   $cmd = "chgrp -Rf hpcbio  $fullMirrorCurrentReleaseDir";
   system($cmd); 
   $cmd = "rm -f $mirrorDir/current_release";
   system($cmd);
   $cmd = "ln -s $fullMirrorCurrentReleaseDir $mirrorDir/current_release";
   system($cmd);
	
}

1;
