#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 1
#SBATCH --mem=20g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J pfam_download
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------
# ----------------Commands------------------------

if [ -z "$1" ];
then
	echo "Please specify pfam version number";
	exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/pfam/$VERSION

echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files"
mkdir -p $MIRROR_DIR
rsync -av rsync://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam${VERSION}/ $MIRROR_DIR/
if [ $? -ne 0 ]
then
	echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files Failed"
else
	echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files Complete"
fi



