#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 1
#SBATCH --mem=20g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J card-prevalence_download
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------
# ----------------Commands------------------------
#
# Replace DATABASE with name of database you are downloading
# Replace WEBSITE with remote location of database
#

DATABASE="card-prevalence"

if [ -z "$1" ];
then
	echo "Please specify ${DATABASE} version number";
	exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/${DATABASE}/${VERSION}/db

echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files"
mkdir -p ${MIRROR_DIR}
wget https://card.mcmaster.ca/download/5/ontology-v${VERSION}.tar.bz2 -O ${MIRROR_DIR}/ontology-v${VERSION}.tar.bz2
if [ $? -ne 0 ]
then
	echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files Failed"
	exit $?
else
	echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files Complete"
fi

wget https://card.mcmaster.ca/download/0/broadstreet-v${VERSION}.tar.bz2 -O ${MIRROR_DIR}/broadstreet-v${VERSION}.tar.bz2
if [ $? -ne 0 ]
then
        echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files Failed"
        exit $?
else
        echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files Complete"
fi

wget https://card.mcmaster.ca/download/6/prevalence-v${VERSION}.tar.bz2 -O ${MIRROR_DIR}/prevalence-v${VERSION}.tar.bz2
if [ $? -ne 0 ]
then
        echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files Failed"
        exit $?
else
        echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files Complete"
fi
