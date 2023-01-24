#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 1
#SBATCH --mem=20g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J gtdb_download
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------
module load lftp
# ----------------Commands------------------------
#
# Replace DATABASE with name of database you are downloading
# Replace WEBSITE with remote location of database
#

DATABASE="gtdb"

if [ -z "$1" ];
then
	echo "Please specify ${DATABASE} version number";
	exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/${DATABASE}/${VERSION}

echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files"
mkdir -p ${MIRROR_DIR}
lftp -c mirror https://data.gtdb.ecogenomic.org/releases/release${VERSION}/${VERSION}.0/ ${MIRROR_DIR}/
if [ $? -ne 0 ]
then
	echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files Failed"
	exit $?
else
	echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files Complete"
fi



