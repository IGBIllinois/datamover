#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 4
#SBATCH --mem=20g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J refseq_extract
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------
module load pigz/2.4-IGB-gcc-8.2.0
# ----------------Commands------------------------

if [ -z "$1" ];
then
        echo "Please specify refseq version number";
        exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/refseq-db

find $MIRROR_DIR -name '*.gz' -exec pigz -p $SLURM_NTASKS -d {} \;


