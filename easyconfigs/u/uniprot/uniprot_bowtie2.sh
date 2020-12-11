#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 4
#SBATCH --mem=40g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J uniprot_bowtie2
# ----------------Load Modules--------------------
module load Bowtie2/2.4.2-IGB-gcc-8.2.0
# ----------------Commands------------------------


UNIPROT_DIR=${uniprot_dir}

FILE_LIST=( uniprot_sprot.fasta.gz uniprot_trembl.fasta.gz uniref100.fasta.gz uniref50.fasta.gz uniref90.fasta.gz )

echo -n "Time Started: "
date "+%Y-%m-%d %k:%M:%S"

if [ -d $UNIPROT_DIR ]; then
	cd $UNIPROT_DIR

	for i in "${FILE_LIST[@]}"; do
		if [ -e $UNIPROT_DIR/$i ] 
		then
			#Extract File
			gzip -d $UNIPROT_DIR/$i
			FASTA_NAME=`basename $i .gz`
			
			DB_NAME=`basename $FASTA_NAME .fasta`
			#Blast+ Indexing
		fi
	done
else
	echo "No Uniprot Directory"

fi
echo -n "Time Finished: "
date "+%Y-%m-%d %k:%M:%S"
