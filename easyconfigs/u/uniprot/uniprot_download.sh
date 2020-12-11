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
# ----------------Load Modules--------------------
module load cURL/.7.53.1-IGB-gcc-8.2.0
module load pigz/2.4-IGB-gcc-8.2.0
# ----------------Commands------------------------

if [ -z "$1" ];
then
	echo "Please specify uniprot version number";
	exit 1;
fi

UNIPROT_VERSION=$1
UNIPROT_DIR=/private_stores/mirror/uniprot
FASTA_DIR=$UNIPROT_DIR/$UNIPROT_VERSION/db

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

pigz -d -p $SLURM_NTASKS $FASTA_DIR/uniprot_sprot.fasta.gz
if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error extracting file: uniprot_sprot.fasta.gz"
                exit 1
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done extracting file: uniprot_sprot.fasta.gz"
        fi

pigz -d -p $SLURM_NTASKS $FASTA_DIR/idmapping.dat.gz
if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error extracting file: idmapping.dat.gz"
                exit 1
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done extracting file: idmapping.dat.gz"
        fi

pigz -d -p $SLURM_NTASKS $FASTA_DIR/uniref100.fasta.gz
if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error extracting file: uniref100.fasta.gz"
                exit 1
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done extracting file: uniref100.fasta.gz"
        fi

pigz -d -p $SLURM_NTASKS $FASTA_DIR/uniref90.fasta.gz
if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error extracting file: uniref90.fasta.gz"
                exit 1
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done extracting file: uniref90.fasta.gz"
        fi

pigz -d -p $SLURM_NTASKS $FASTA_DIR/uniref50.fasta.gz
if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error extracting file: uniref50.fasta.gz"
                exit 1
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done extracting file: uniref50.fasta.gz"
        fi

pigz -d -p $SLURM_NTASKS $FASTA_DIR/uniprot_trembl.fasta.gz
if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error extracting file: uniprot_trembl.fasta.gz"
                exit 1
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done extracting file: uniprot_trembl.fasta.gz"
        fi


echo "Extracting Files Complete: `date "+%Y-%m-%d %k:%M:%S"`"

