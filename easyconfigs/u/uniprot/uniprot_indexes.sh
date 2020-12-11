#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 4
#SBATCH --mem=40g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J uniprot_indexes
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

UNIPROT_VERSION=$1
UNIPROT_DIR=/private_stores/mirror/uniprot
FASTA_DIR=$UNIPROT_DIR/$UNIPROT_VERSION/db
BLASTV4_DIR=$UNIPROT_DIR/$UNIPROT_VERSION/blastdb_v4
BLASTV5_DIR=$UNIPROT_DIR/$UNIPROT_VERSION/blastdb_v5
DIAMOND_DIR=$UNIPROT_DIR/$UNIPROT_VERSION/diamond
BOWTIE_DIR=$UNIPROT_DIR/$UNIPROT_VERSION/bowtie
BOWTIE2_DIR=$UNIPROT_DIR/$UNIPROT_VERSION/bowtie2


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

	#Make blast v4 indexes
	echo "`date "+%Y-%m-%d %k:%M:%S"` Creating Blast v4 Index for File: $f"
	FASTA_NAME=`basename $f`
	DB_NAME=`basename $f .fasta`
	makeblastdb -dbtype prot -title $DB_NAME -in $f -out $BLASTV4_DIR/$DB_NAME -blastdb_version 4
	if [ $? -ne 0 ]; then
		echo "`date "+%Y-%m-%d %k:%M:%S"` Error creating Blast v4 index for file: $f"
		exit 1
	else
		echo "`date "+%Y-%m-%d %k:%M:%S"` Done Creating Blast v4 Index for File: $f"
	fi

	#Make blast v5 indexes
        echo "`date "+%Y-%m-%d %k:%M:%S"` Creating Blast v5 Index for File: $f"
	makeblastdb -dbtype prot -title $DB_NAME -in $f -out $BLASTV5_DIR/$DB_NAME -blastdb_version 5
        if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error creating Blast v5 index for file: $f"
                exit 1
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done Creating Blast v5 Index for File: $f"
        fi

	#Make Diamond indexes
	echo "`date "+%Y-%m-%d %k:%M:%S"` Creating diamond Index for File: $f"
        makedb $f $DIAMOND_DIR/$DB_NAME.dmnd
        if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error creating diamond index for file: $f"
                exit 1
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done Creating diamond Index for File: $f"
        fi



	#Make bowtie indexes
	echo "`date "+%Y-%m-%d %k:%M:%S"` Creating bowtie Index for File: $f"
	
        bowtie-build --threads $SLURM_NTASKS $f $BOWTIE_DIR/$DB_NAME
        if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error creating bowtie2 index for file: $f"
                exit 1
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done Creating bowtie Index for File: $f"
        fi


	#Make bowtie2 indexes
	echo "`date "+%Y-%m-%d %k:%M:%S"` Creating bowtie2 Index for File: $f"
        bowtie2-build --threads $SLURM_NTASKS $f $BOWTIE2_DIR/$DB_NAME 
        if [ $? -ne 0 ]; then
                echo "`date "+%Y-%m-%d %k:%M:%S"` Error creating bowtie2 index for file: $f"
                exit 1
        else
                echo "`date "+%Y-%m-%d %k:%M:%S"` Done Creating bowtie2 Index for File: $f"
        fi


done
echo "`date "+%Y-%m-%d %k:%M:%S"` Finshed"
