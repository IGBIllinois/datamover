#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 4
#SBATCH --mem=20g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J checkv-db_extract
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------
module load pigz/2.4-IGB-gcc-8.2.0
# ----------------Commands------------------------
#
# Replace DATABASE with name of database you are downloading
# Replace WEBSITE with remote location of database#
#

DATABASE="checkv-db"

if [ -z "$1" ];
then
	echo "Please specify ${DATABASE} version number";
	exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/${DATABASE}/${VERSION}


echo "`date "+%Y-%m-%d %k:%M:%S"` Extracting tar.gz Files"
for f in $(find ${MIRROR_DIR} -name '*.tar.gz');
do
	tar -xvzf $f -C `dirname $f`
	if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error extracting file: $f"
                exit $?
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done extracting file: $f"
        fi
done

#Run diamond to create index
diamond makedb -p $SLURM_NTASKS --in ${MIRROR_DIR}/checkv-db-v${VERSION}/genome_db/checkv_reps.faa --db ${MIRROR_DIR}/checkv-db-v${VERSION}/genome_db/checkv_reps.dmnd
echo "`date "+%Y-%m-%d %k:%M:%S"` Fix Permissions Start"
find ${MIRROR_DIR} -type d -exec chmod 775 {} \;
find ${MIRROR_DIR} -type f -exec chmod 664 {} \;
echo "`date "+%Y-%m-%d %k:%M:%S"` Fix Permissions Completed"

