#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 4
#SBATCH --mem=40g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J uniprot_diamond
# ----------------Load Modules--------------------
module load DIAMOND/0.9.24-IGB-gcc-8.2.0
# ----------------Commands------------------------


UNIPROT_DIR=$1

FASTA_DIR="${UNIPROT_DIR}/db"

FILE_LIST=( uniprot_sprot.fasta uniprot_trembl.fasta uniref100.fasta uniref50.fasta uniref90.fasta )

echo -n "Time Started: `date "+%Y-%m-%d %k:%M:%S"`

if [ -d $UNIPROT_DIR ]; then
	cd $UNIPROT_DIR

	for i in "${FILE_LIST[@]}"; do
		if [ -e $FASTA_DIR/$i ] 
		then
			DB_NAME=`basename $FASTA_NAME .fasta`
			diamond makedb
		fi
	done
else
	echo "No Uniprot Directory"

fi
echo -n "Time Finished: `date "+%Y-%m-%d %k:%M:%S"`"
