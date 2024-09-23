#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 1
#SBATCH --mem=20g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J pfam_extract
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
MIRROR_DIR=/private_stores/mirror/pfam/${VERSION}


echo "`date "+%Y-%m-%d %k:%M:%S"` Extracting Files"

echo "`date "+%Y-%m-%d %k:%M:%S"` Extracting .gz Files"
for f in $(find ${MIRROR_DIR} -name '*.gz');
do
        gunzip $f
        if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error extracting file: $f"
                exit $?
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done extracting file: $f"
        fi
done

echo "`date "+%Y-%m-%d %k:%M:%S"` Extracting .tgz Files"
for f in $(find ${MIRROR_DIR} -name '*.tgz');
do
        tar -xvzf $f -C `dirname $f`
	if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error extracting file: $f"
                exit $?
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done extracting file: $f"
        fi
done

echo "`date "+%Y-%m-%d %k:%M:%S"` Fix Permissions Start"
find $MIRROR_DIR -type d -exec chmod 775 {} \;
find $MIRROR_DIR -type f -exec chmod 664 {} \;
echo "`date "+%Y-%m-%d %k:%M:%S"` Fix Permissions Completed"

