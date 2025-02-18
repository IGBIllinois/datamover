#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p normal
#SBATCH -n 8
#SBATCH --mem=256g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J ncbi-blastdb_indexes
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------
module load DIAMOND/2.1.11-IGB-gcc-8.2.0

# ----------------Commands------------------------


if [ -z "$1" ];
then
        echo "Please specify ncbi blastdb version number";
        exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/ncbi-blastdb
FASTA_DIR=$MIRROR_DIR/$VERSION/db
DIAMOND_DIR=$MIRROR_DIR/$VERSION/diamond
DIAMOND_OPTS="--ignore-warnings --quiet --threads $SLURM_NTASKS"

FILES="$FASTA_DIR/nr
$FASTA_DIR/nt
$FASTA_DIR/pdbaa
$FASTA_DIR/swissprot"


if [ ! -d $FASTA_DIR ]
then
        echo "$FASTA_DIR does not exist"
        exit 1
fi


echo "`date "+%Y-%m-%d %k:%M:%S"` Creating Directories"
mkdir -p $DIAMOND_DIR

for f in $FILES
do
	echo "`date "+%Y-%m-%d %k:%M:%S"` Creating Indexes for File: $f"

	FASTA_NAME=`basename $f`
	DB_NAME=`basename $f .fasta`
	
	#Make Diamond indexes
	echo "`date "+%Y-%m-%d %k:%M:%S"` Creating diamond Index for File: $f"
        diamond makedb $DIAMOND_OPTS --in $f --db $DIAMOND_DIR/$DB_NAME
        if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error creating diamond index for file: $f"
                exit 1
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done Creating diamond Index for File: $f"
        fi


done
echo "`date "+%Y-%m-%d %k:%M:%S"` Finshed"
