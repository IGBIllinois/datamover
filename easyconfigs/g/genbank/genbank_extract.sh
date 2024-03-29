#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 4
#SBATCH --mem=20g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J genbank_extract
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------
module load pigz/2.4-IGB-gcc-8.2.0
# ----------------Commands------------------------

if [ -z "$1" ];
then
	echo "Please specify genbank version number";
	exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/genbank/${VERSION}


echo "Extracting Files: `date "+%Y-%m-%d %k:%M:%S"`"

find ${MIRROR_DIR} -type f -name '*.gz' -exec pigz -p ${SLURM_NTASKS} -dr {} \;
if [ $? -ne 0 ]
then
        echo "`date "+%Y-%m-%d %k:%M:%S"` Extracting files Failed"
        exit $?;
else
        echo "`date "+%Y-%m-%d %k:%M:%S"` Extracting Files Complete"
fi

echo "Fix Permissions Start: `date "+%Y-%m-%d %k:%M:%S"`"
find ${MIRROR_DIR} -type d -exec chmod 775 {} \;
find ${MIRROR_DIR} -type f -exec chmod 664 {} \;
echo "Fix Permissions Completed: `date "+%Y-%m-%d %k:%M:%S"`"

