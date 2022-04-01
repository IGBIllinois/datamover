#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 4
#SBATCH --mem=20g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J refseq_download
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------

# ----------------Commands------------------------

if [ -z "$1" ];
then
        echo "Please specify refseq version number";
        exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/refseq-db

mkdir -p /private_stores/mirror/refseq-db/${VERSION}/db
rsync -av rsync://ftp.ncbi.nlm.nih.gov/refseq/release/ /private_stores/mirror/refseq-db/${VERSION}/db/
