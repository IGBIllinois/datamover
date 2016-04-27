#!/bin/bash
#PBS -j oe
#PBS -N uniprot_extract
#PBS -q default
#PBS -M dslater@igb.illinois.edu
#PBS -m abe
#PBS -d /home/a-m/datamover/log

UNIPROT_DIR=${uniprot_dir}

FILE_LIST=( idmapping.dat.gz uniprot_sprot.fasta.gz uniprot_trembl.fasta.gz uniref100.fasta.gz uniref50.fasta.gz uniref90.fasta.gz )

echo -n "Time Started: "
date "+%Y-%m-%d %k:%M:%S"

if [ -d $UNIPROT_DIR ]; then
	cd $UNIPROT_DIR

	for i in "${FILE_LIST[@]}"; do
		if [ -e $UNIPROT_DIR/$i ] 
		then
			gzip -d $UNIPROT_DIR/$i
		fi
	done
else
	echo "No Uniprot Directory"

fi
echo -n "Time Finished: "
date "+%Y-%m-%d %k:%M:%S"
