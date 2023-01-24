#!/usr/bin/env perl

use strict;

my $bioc_dir="/private_stores/mirror/R/bioconductor";
my $bioc_exclude="--exclude='bin'";
my $cran_dir="/private_stores/mirror/R/cran";
my $cran_exclude="--exclude='bin'";

my @bioc_versions = ('3.8','3.9','3.10','3.12','3.14');

foreach my $version (@bioc_versions) {
	
	#Rsync the files
	my $command ="rsync -e 'ssh -i ~/.ssh/id_rsa' -zrtlv --delete $bioc_exclude bioc-rsync\@master.bioconductor.org:$version/ $bioc_dir/packages/$version/";
	print $command . "\n";
	system($command);

	#Fix permissions on directories
	my $permission_dirs = "find $bioc_dir/packages/$version -type d -exec chmod 775 {} \\;";
	print $permission_dirs . "\n";
	system($permission_dirs);
	#Fix permissions on files
	my $permission_files = "find $bioc_dir/packages/$version -type f -exec chmod 664 {} \\;";
	print $permission_files . "\n";
	system($permission_files);
	
	
}


#Bioconductor source script
my $command="wget -r --no-directories --directory-prefix=$bioc_dir http://bioconductor.org/biocLite.R";
print $command;
system($command);

#CRAN
my $command ="rsync -rtlzv --delete $cran_exclude cran.r-project.org::CRAN $cran_dir";
print $command;
system($command);

