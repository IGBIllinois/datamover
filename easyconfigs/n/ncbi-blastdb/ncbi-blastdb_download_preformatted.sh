#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 1
#SBATCH --mem=20g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J ncbi-blastdb_download
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------
module load BLAST+/2.16.0-IGB-gcc-8.2.0

# ----------------Commands------------------------

if [ -z "$1" ];
then
	echo "Please specify ncbi-blastdb version number";
	exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/ncbi-blastdb
BLASTV5_DIR=$MIRROR_DIR/$VERSION/blastdb_v5

echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading blastdb_v5 preformmatted"
mkdir -p $BLASTV5_DIR
DATABASES=`update_blastdb.pl --showall`

for d in $DATABASES
do
	if [ "$d" != "Connected" ] && [ "$d" != "to" ] && [ "$d" != "NCBI" ]; then
		cd $BLASTV5_DIR && update_blastdb.pl --num_threads $SLURM_NTASKS --force --decompress $d
		if [ $? -ne 0 ]; then
		        echo "`date "+%Y-%m-%d %k:%M:%S"` Error downloading blastdb_v5 preformatted database: $d"
		        exit 1
		else
		        echo "`date "+%Y-%m-%d %k:%M:%S"` Finished downloading blastdb_v5 preformatted database: $d"
		fi

	fi 
done
