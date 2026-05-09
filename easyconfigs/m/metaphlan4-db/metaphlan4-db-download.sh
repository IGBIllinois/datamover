#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 1
#SBATCH --mem=20g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J metaphlan4-db-download
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------
module load metaphlan/4.2.4-IGB-gcc-8.2.0-Python-3.10.1
# ----------------Commands------------------------
#
# Replace DATABASE with name of database you are downloading
# Replace WEBSITE with remote location of database
#

DATABASE="metaphlan4-db"

if [ -z "$1" ];
then
	echo "Please specify ${DATABASE} version number";
	exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/${DATABASE}/${VERSION}

echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files"
mkdir -p ${MIRROR_DIR}

metaphlan --install --db_dir $MIRROR_DIR
if [ $? -ne 0 ]
then
	echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading latest database Failed"
	exit $?
else
	echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading latest database Complete"
fi

index=("mpa_vFeb24_CDIFF_CHOCOPhlAnSGB_20240910"
	"mpa_vJan21_CHOCOPhlAnSGB_202103"
	"mpa_vJan21_TOY_CHOCOPhlAnSGB_202103"
	"mpa_vJan25_CHOCOPhlAnSGB_202503"
	"mpa_vJun23_CHOCOPhlAnSGB_202307"
	"mpa_vJun23_CHOCOPhlAnSGB_202403"
	"mpa_vOct22_CHOCOPhlAnSGB_202212"
	"mpa_vOct22_CHOCOPhlAnSGB_202403")

for item in "${index[@]}"; do
	echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading $item index"
	metaphlan --install --index $item --db_dir $MIRROR_DIR
	if [ $? -ne 0 ]
	then
	       	echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading $item index Failed"
	        exit $?
	else
       	echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading $item index Complete"
	fi

done

echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files Complete"



