#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 1
#SBATCH --mem=20g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J DATABASE_download
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------
# ----------------Commands------------------------
#
# Replace DATABASE with name of database you are downloading
# Replace WEBSITE with remote location of database
#

DATABASE="kraken2-db"

if [ -z "$1" ];
then
	echo "Please specify ${DATABASE} version number";
	exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/${DATABASE}/${VERSION}

echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files"
mkdir -p ${MIRROR_DIR}
mkdir -p ${MIRROR_DIR}/k2_viral
wget -P $MIRROR_DIR/k2_viral https://genome-idx.s3.amazonaws.com/kraken/k2_viral_${VERSION}.tar.gz
mkdir -p ${MIRROR_DIR}/k2_minusb
wget -P $MIRROR_DIR/k2_minusb https://genome-idx.s3.amazonaws.com/kraken/k2_minusb_${VERSION}.tar.gz
mkdir -p ${MIRROR_DIR}/k2_standard
wget -P $MIRROR_DIR/k2_standard https://genome-idx.s3.amazonaws.com/kraken/k2_standard_${VERSION}.tar.gz
wget -P $MIRROR_DIR https://genome-idx.s3.amazonaws.com/kraken/k2_standard_08gb_${VERSION}.tar.gz
mkdir -p ${MIRROR_DIR}/k2_standard_16gb
wget -P $MIRROR_DIR/k2_standard_16gb  https://genome-idx.s3.amazonaws.com/kraken/k2_standard_16gb_${VERSION}.tar.gz
mkdir -p ${MIRROR_DIR}/k2_pluspf
wget -P $MIRROR_DIR/k2_pluspf  https://genome-idx.s3.amazonaws.com/kraken/k2_pluspf_${VERSION}.tar.gz
mkdir -p ${MIRROR_DIR}/k2_pluspf_08gb
wget -P $MIRROR_DIR/k2_pluspf_08gb https://genome-idx.s3.amazonaws.com/kraken/k2_pluspf_08gb_${VERSION}.tar.gz
mkdir -p ${MIRROR_DIR}/k2_pluspf_16gb
wget -P $MIRROR_DIR/k2_pluspf_16gb https://genome-idx.s3.amazonaws.com/kraken/k2_pluspf_16gb_${VERSION}.tar.gz
mkdir -p ${MIRROR_DIR}/k2_pluspfp
wget -P $MIRROR_DIR/k2_pluspfp https://genome-idx.s3.amazonaws.com/kraken/k2_pluspfp_${VERSION}.tar.gz
mkdir -p ${MIRROR_DIR}/k2_pluspfp_08gb
wget -P $MIRROR_DIR/k2_pluspfp_08gb https://genome-idx.s3.amazonaws.com/kraken/k2_pluspfp_08gb_${VERSION}.tar.gz
mkdir -p ${MIRROR_DIR}/k2_pluspfp_16gb
wget -P $MIRROR_DIR}/k2_pluspfp_16gb https://genome-idx.s3.amazonaws.com/kraken/k2_pluspfp_16gb_${VERSION}.tar.gz
mkdir -p ${MIRROR_DIR}/k2_eupathdb48
wget -P $MIRROR_DIR/k2_eupathdb48 https://genome-idx.s3.amazonaws.com/kraken/k2_eupathdb48_20201113.tar.gz




