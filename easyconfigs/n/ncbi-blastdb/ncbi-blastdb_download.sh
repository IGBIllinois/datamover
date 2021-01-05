#!/bin/bash
# ----------------SLURM Parameters----------------
#SBATCH -p admin
#SBATCH -n 4
#SBATCH --mem=20g
#SBATCH -N 1
#SBATCH --mail-user=datamover@igb.illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J ncbi-blastdb_download
#SBATCH -D /home/a-m/datamover/jobs
#SBATCH -o %x-%j.out
# ----------------Load Modules--------------------
module load BLAST+/2.10.1-IGB-gcc-8.2.0
module load cURL/.7.53.1-IGB-gcc-8.2.0
module load pigz/2.4-IGB-gcc-8.2.0
# ----------------Commands------------------------

if [ -z "$1" ];
then
	echo "Please specify ncbi-blastdb version number";
	exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/ncbi-blastdb
FASTA_DIR=$MIRROR_DIR/$VERSION/db
BLASTV5_DIR=$MIRROR_DIR/$VERSION/blastdb_v5

echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading fasta files"
mkdir -p $FASTA_DIR
cd $FASTA_DIR && curl -s -O https://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nr.gz
cd $FASTA_DIR && curl -s -O https://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nr.gz.md5
cd $FASTA_DIR && curl -s -O https://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nt.gz
cd $FASTA_DIR && curl -s -O https://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nt.gz.md5
cd $FASTA_DIR && curl -s -O https://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/pdbaa.gz
cd $FASTA_DIR && curl -s -O https://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/pdbaa.gz.md5
cd $FASTA_DIR && curl -s -O https://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/swissprot.gz
cd $FASTA_DIR && curl -s -O https://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/swissprot.gz.md5
cd $FASTA_DIR && curl -s -O https://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz
cd $FASTA_DIR && curl -s -O https://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz.md5
cd $FASTA_DIR && curl -s -O https://ftp.ncbi.nlm.nih.gov/blast/db/README

echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading fasta files Complete"


echo "`date "+%Y-%m-%d %k:%M:%S"` Verifying fasta md5sum"
for f in $FASTA_DIR/*.gz
do
	cd $FASTA_DIR && md5sum --check $f.md5
	if [ $? -ne 0 ]; then
	        echo "`date "+%Y-%m-%d %k:%M:%S"` Error md5sum file: $f"
	       	exit 1
	else
        	echo "`date "+%Y-%m-%d %k:%M:%S"` Done md5sum sucess: $f"
	fi

done
echo "`date "+%Y-%m-%d %k:%M:%S"` Done Verifying md5sum"


echo "`date "+%Y-%m-%d %k:%M:%S"` Extracting Files"
for f in $FASTA_DIR/*.gz
do
	if [ "$f" == "*.tar.gz" ]; then
		tar -I pigz -xvf $f	
	else
	        pigz -d -p $SLURM_NTASKS $f
	fi
        if [ $? -ne 0 ]; then
       	        echo "`date "+%Y-%m-%d %k:%M:%S"` Error extracting file: $f"
               	exit 1
        else
       	        echo "`date "+%Y-%m-%d %k:%M:%S"` Done extracting file: $f"
        fi

done

echo "`date "+%Y-%m-%d %k:%M:%S"` Extracting Files Complete"



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
