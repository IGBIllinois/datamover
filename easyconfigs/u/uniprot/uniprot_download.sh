#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 1
#SBATCH --mem=20g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J uniprot_download
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------
# ----------------Commands------------------------

if [ -z "$1" ];
then
	echo "Please specify uniprot version number";
	exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/uniprot/${VERSION}
FASTA_DIR=${MIRROR_DIR}/db

echo "Downloading Files: `date "+%Y-%m-%d %k:%M:%S"`"
mkdir -p ${FASTA_DIR}
rsync -av --delete --exclude 'rdf' --exclude 'knowledgebase/pan_proteomes' --exclude 'knowledgebase/proteomics_mapping' \
--exclude 'knowledgebase/reference_proteomes' --exclude 'knowledgebase/variants' --exclude 'knowledgebase/genome_annotation_tracks' \
--exclude 'knowledgebase/taxonomic_divisions' rsync://ftp.ebi.ac.uk/pub/databases/uniprot/current_release/ ${FASTA_DIR}

if [ $? -ne 0 ]
then
        echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files Failed"
        exit $?
else
        echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files Complete"
fi


