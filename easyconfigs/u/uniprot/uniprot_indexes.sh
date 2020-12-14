#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p normal
#SBATCH -n 16
#SBATCH --mem=256g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J uniprot_indexes
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------
module load BLAST+/2.10.1-IGB-gcc-8.2.0
module load Bowtie/1.3.0-IGB-gcc-8.2.0
module load Bowtie2/2.4.2-IGB-gcc-8.2.0
module load DIAMOND/0.9.24-IGB-gcc-8.2.0

# ----------------Commands------------------------


if [ -z "$1" ];
then
        echo "Please specify uniprot version number";
        exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/uniprot
FASTA_DIR=$MIRROR_DIR/$VERSION/db
BLASTV4_DIR=$MIRROR_DIR/$VERSION/blastdb_v4
BLASTV5_DIR=$MIRROR_DIR/$VERSION/blastdb_v5
DIAMOND_DIR=$MIRROR_DIR/$VERSION/diamond
DIAMOND_OPTS="--quiet --threads $SLURM_NTASKS"
BOWTIE_DIR=$MIRROR_DIR/$VERSION/bowtie
BOWTIE_OPTS="--large-index --threads $SLURM_NTASKS"
BOWTIE2_DIR=$MIRROR_DIR/$VERSION/bowtie2
BOWTIE2_OPTS="--large-index --threads $SLURM_NTASKS"


if [ ! -d $FASTA_DIR ]
then
        echo "$FASTA_DIR does not exist"
        exit 1
fi

echo "`date "+%Y-%m-%d %k:%M:%S"` Started Blast Indexing"

echo "`date "+%Y-%m-%d %k:%M:%S"` Creating Directories"
mkdir -p $BLASTV4_DIR
mkdir -p $BLASTV5_DIR
mkdir -p $DIAMOND_DIR
mkdir -p $BOWTIE_DIR
mkdir -p $BOWTIE2_DIR

for f in $FASTA_DIR/*.fasta
do
	echo "`date "+%Y-%m-%d %k:%M:%S"` Creating Indexes for File: $f"

	FASTA_NAME=`basename $f`
	DB_NAME=`basename $f .fasta`
	
	#Make blast v4 indexes
        echo "`date "+%Y-%m-%d %k:%M:%S"` Creating Blast v4 Index for File: $f"

	#makeblastdb -dbtype prot -title $DB_NAME -in $f -out $BLASTV4_DIR/$DB_NAME -blastdb_version 4
	if [ $? -ne 0 ]; then
		echo "`date "+%Y-%m-%d %k:%M:%S"` Error creating Blast v4 index for file: $f"
		exit 1
	else
		echo "`date "+%Y-%m-%d %k:%M:%S"` Done Creating Blast v4 Index for File: $f"
	fi

	#Make blast v5 indexes
        echo "`date "+%Y-%m-%d %k:%M:%S"` Creating Blast v5 Index for File: $f"
	#makeblastdb -dbtype prot -title $DB_NAME -in $f -out $BLASTV5_DIR/$DB_NAME -blastdb_version 5
        if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error creating Blast v5 index for file: $f"
                exit 1
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done Creating Blast v5 Index for File: $f"
        fi

	#Make Diamond indexes
	echo "`date "+%Y-%m-%d %k:%M:%S"` Creating diamond Index for File: $f"
        #diamond makedb $DIAMOND_OPTS --in $f --db $DIAMOND_DIR/$DB_NAME
        if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error creating diamond index for file: $f"
                exit 1
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done Creating diamond Index for File: $f"
        fi



	#Make bowtie indexes
	echo "`date "+%Y-%m-%d %k:%M:%S"` Creating bowtie Index for File: $f"
	
        bowtie-build $BOWTIE_OPTS $f $BOWTIE_DIR/$DB_NAME
        if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error creating bowtie index for file: $f"
                exit 1
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done Creating bowtie Index for File: $f"
        fi


	#Make bowtie2 indexes
	echo "`date "+%Y-%m-%d %k:%M:%S"` Creating bowtie2 Index for File: $f"
        bowtie2-build $BOWTIE2_OPTS $f $BOWTIE2_DIR/$DB_NAME 
        if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error creating bowtie2 index for file: $f"
                exit 1
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done Creating bowtie2 Index for File: $f"
        fi


done
echo "`date "+%Y-%m-%d %k:%M:%S"` Finshed"
