# ----------------Load Modules--------------------
module load globus-cli/3.30.1-IGB-gcc-8.2.0-Python-3.10.1

# ----------------Commands------------------------

if [ -z "$1" ];
then
	echo "Please specify uniprot version number";
	exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/uniprot/${VERSION}
FASTA_DIR=${MIRROR_DIR}/db

echo "Downloading Files: `date "+%Y-%m-%d %k:%M:%S"`"
mkdir -p ${FASTA_DIR}
globus transfer -r --exclude "reference_proteomes" --exclude "taxonomic_divisions" "47772002-3e5b-4fd3-b97c-18cee38d6df2:/pub/databases/uniprot/current_release/" "4a467fda-f559-4fc3-b54a-e2842f439e06:${FASTA_DIR}/"



