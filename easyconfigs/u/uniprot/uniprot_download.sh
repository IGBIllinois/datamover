#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 4
#SBATCH --mem=20g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J uniprot_download
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------
module load cURL/.7.53.1-IGB-gcc-8.2.0
module load pigz/2.4-IGB-gcc-8.2.0
# ----------------Commands------------------------

if [ -z "$1" ];
then
	echo "Please specify uniprot version number";
	exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/uniprot
FASTA_DIR=$MIRROR_DIR/$VERSION/db

echo "Downloading Files: `date "+%Y-%m-%d %k:%M:%S"`"
mkdir -p $FASTA_DIR
cd $FASTA_DIR && curl -s -O ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/relnotes.txt
cd $FASTA_DIR && curl -s -O ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
cd $FASTA_DIR && curl -s -O ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping.dat.gz
cd $FASTA_DIR && curl -s -O ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/uniref/uniref100/uniref100.fasta.gz
cd $FASTA_DIR && curl -s -O ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/uniref/uniref90/uniref90.fasta.gz
cd $FASTA_DIR && curl -s -O ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/uniref/uniref50/uniref50.fasta.gz
cd $FASTA_DIR && curl -s -O ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_trembl.fasta.gz
echo "Downloading Files Complete: `date "+%Y-%m-%d %k:%M:%S"`"


echo "Extracting Files: `date "+%Y-%m-%d %k:%M:%S"`"

for f in $FASTA_DIR/*.gz
do
	pigz -d -p $SLURM_NTASKS $FASTA_DIR/$f
	if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error extracting file: $f"
                exit 1
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done extracting file: $f"
        fi


done

echo "Extracting Files Complete: `date "+%Y-%m-%d %k:%M:%S"`"

