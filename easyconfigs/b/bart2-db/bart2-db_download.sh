#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 1
#SBATCH --mem=20g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J bart2-db_download
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------
# ----------------Commands------------------------
#
# Replace DATABASE with name of database you are downloading
# Replace WEBSITE with remote location of database
#

DATABASE="bart2-db"

if [ -z "$1" ];
then
	echo "Please specify ${DATABASE} version number";
	exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/${DATABASE}/${VERSION}

echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files"
mkdir -p ${MIRROR_DIR}
wget https://virginia.box.com/shared/static/2kqczz9gixetcr9p4bl650uyrio5zd33.gz -O ${MIRROR_DIR}/hg38_library.tar.gz
if [ $? -ne 0 ]
then
        echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading File hg38_library.tar.gz Failed"
        exit $?
else
        echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading File hg38_library.tar.gz Complete"
fi

wget https://virginia.box.com/shared/static/bxdggnhp4bjz2l5h2zjlisnzp0ac7axf.gz -O ${MIRROR_DIR}/mm10_library.tar.gz
if [ $? -ne 0 ]
then
	echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading File mm10_library.tar.gz"
	exit $?
else
	echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading File mm10_library.tar.gz Complete"
fi



