#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 4
#SBATCH --mem=20g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J pfam_extract
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------
module load pigz/2.4-IGB-gcc-8.2.0
# ----------------Commands------------------------

if [ -z "$1" ];
then
	echo "Please specify pfam version number";
	exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/pfam/${VERSION}


echo "`date "+%Y-%m-%d %k:%M:%S"` Extracting Files"

pigz -p $SLURM_NTASKS -r $MIRROR_DIR
if [ $? -ne 0 ]
then
	echo "`date "+%Y-%m-%d %k:%M:%S"` Extracting files Failed"
	exit 1
else
	echo "Extracting Files Complete: `date "+%Y-%m-%d %k:%M:%S"`"
fi

echo "`date "+%Y-%m-%d %k:%M:%S"` Fix Permissions Start"
find $MIRROR_DIR -type d -exec chmod 775 {} \;
find $MIRROR_DIR -type f -exec chmod 664 {} \;
echo "`date "+%Y-%m-%d %k:%M:%S"` Fix Permissions Completed"

