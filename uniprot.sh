#!/bin/bash

export PATH=`pwd`:$PATH
#Download Fasta Files
getUniprotFasta.pl -f uniprotFileList.txt 

#If new release then unzip and blast format them
if [ $? -eq 0 ]; then
	qsub -v uniprot_dir=/home/mirrors/uniprot/current_release uniprot_format.sh
fi
