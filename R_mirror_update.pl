#!/usr/bin/perl

use strict;

my $bioc_dir="/home/mirrors/no_backup/R/bioconductor";
#my $bioc_exclude="--exclude='/bin/' --exclude='/bioc/bin/' --exclude='/data/annotation/bin/'";
my $bioc_exclude="--exclude='*bin*'";
my $cran_dir="/home/mirrors/no_backup/R/cran";
my $cran_exclude="--exclude='*bin*'";

my @bioc_versions = ('2.12','2.13','2.14','3.0','3.1','3.2');

foreach my $version (@bioc_versions) {
	
	#Rsync the files
	my $command ="rsync -zrtlv --delete $bioc_exclude master.bioconductor.org::$version $bioc_dir/packages/$version";
	print $command . "\n";
	system($command);

	#Fix permissions on directories
	my $permission_dirs = "find $bioc_dir/packages/$version -type d -exec chmod 775 {} \;";
	print $permission_dirs . "\n";
	system($permission_dirs);
	#Fix permissions on files
	my $permission_files = "find $bioc_dir/packages/$version -type f -exec chmod 664 {}\;";
	print $permission_files . "\n";
	system($permission_files);
	
	
}


#Bioconductor source script
my $command="wget -r --no-directories --directory-prefix=$bioc_dir http://bioconductor.org/biocLite.R";
print $command;
system($command);

#CRAN
my $command ="rsync -rtlzv --delete $cran_exclude cran.r-project.org::CRAN /home/mirrors/no_backup/R/cran";
print $command;
system($command);
