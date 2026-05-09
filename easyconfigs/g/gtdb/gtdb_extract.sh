#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 1
#SBATCH --mem=15g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J gtdb_extract
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------
# ----------------Commands------------------------
#
# Replace DATABASE with name of database you are downloading
# Replace WEBSITE with remote location of database#
#

DATABASE="gtdb"

if [ -z "$1" ];
then
	echo "Please specify ${DATABASE} version number";
	exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/${DATABASE}/${VERSION}


echo "`date "+%Y-%m-%d %k:%M:%S"` Extracting Files"

find ${MIRROR_DIR} -path '${MIRROR_DIR}/auxillary_files/gtdbtk_package/full_package/release$VERSION' -prune -o  -path '${MIRROR_DIR}/genomic_files_reps/gtdb_genomes_reps_r$VERSION' -prune -o -type f -name '*.tar.gz' -execdir tar -xf {} \;
if [ $? -ne 0 ]
then
	echo "`date "+%Y-%m-%d %k:%M:%S"` Extracting tar.gz files Failed"
	exit $?
else
	echo "`date "+%Y-%m-%d %k:%M:%S"` Extracting tar.gz Files Complete"
fi

echo "`date "+%Y-%m-%d %k:%M:%S"` Deleting tar.gz Files"

find ${MIRROR_DIR} -path '${MIRROR_DIR}/auxillary_files/gtdbtk_package/full_package/release$VERSION' -prune -o -path '${MIRROR_DIR}/genomic_files_reps/gtdb_genomes_reps_r$VERSION' -prune -o -type f -name '*.tar.gz' -exec rm -f {} \;
if [ $? -ne 0 ]
then
        echo "`date "+%Y-%m-%d %k:%M:%S"` Delete files Failed"
        exit $?
else
        echo "`date "+%Y-%m-%d %k:%M:%S"` Delete Files Complete"
fi

echo "`date "+%Y-%m-%d %k:%M:%S"` Fix Permissions Start"
find ${MIRROR_DIR} -type d -exec chmod 775 {} \;
find ${MIRROR_DIR} -type f -exec chmod 664 {} \;
echo "`date "+%Y-%m-%d %k:%M:%S"` Fix Permissions Completed"

