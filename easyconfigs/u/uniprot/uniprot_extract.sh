#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 4
#SBATCH --mem=20g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J uniprot_extract
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------
module load pigz/2.4-IGB-gcc-8.2.0
# ----------------Commands------------------------
#
# Replace DATABASE with name of database you are downloading
# Replace WEBSITE with remote location of database#
#

DATABASE="uniprot"

if [ -z "$1" ];
then
	echo "Please specify ${DATABASE} version number";
	exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/${DATABASE}/${VERSION}
FASTA_DIR=${MIRROR_DIR}/db

echo "`date "+%Y-%m-%d %k:%M:%S"` Directory: ${FASTA_DIR}"
echo "`date "+%Y-%m-%d %k:%M:%S"` Extracting Files"

pigz -p ${SLURM_NTASKS} -dr ${FASTA_DIR}
if [ $? -ne 0 ]
then
	echo "`date "+%Y-%m-%d %k:%M:%S"` Extracting files Failed"
	exit $?
else
	echo "`date "+%Y-%m-%d %k:%M:%S"` Extracting Files Complete"
fi

echo "`date "+%Y-%m-%d %k:%M:%S"` Fix Permissions Start"
find ${FASTA_DIR} -type d -exec chmod 775 {} \;
find ${FASTA_DIR} -type f -exec chmod 664 {} \;
echo "`date "+%Y-%m-%d %k:%M:%S"` Fix Permissions Completed"

