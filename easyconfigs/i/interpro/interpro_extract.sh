#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 1
#SBATCH --mem=20g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J interpro_extract
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------

# ----------------Commands------------------------
#
# Replace DATABASE with name of database you are downloading
# Replace WEBSITE with remote location of database#
#

DATABASE="interpro"

if [ -z "$1" ];
then
	echo "Please specify ${DATABASE} version number";
	exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/${DATABASE}/${VERSION}


echo "`date "+%Y-%m-%d %k:%M:%S"` Extracting Files"
for f in $(find ${MIRROR_DIR} -name '*.gz');
do
	gunzip $f
	if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error extracting file: $f"
                exit 1
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done extracting file: $f"
        fi
done

echo "`date "+%Y-%m-%d %k:%M:%S"` Fix Permissions Start"
find ${MIRROR_DIR} -type d -exec chmod 775 {} \;
find ${MIRROR_DIR} -type f -exec chmod 664 {} \;
echo "`date "+%Y-%m-%d %k:%M:%S"` Fix Permissions Completed"

