# ----------------Load Modules--------------------
module load globus-cli/3.10.1-IGB-gcc-8.2.0-Python-3.7.2

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
globus transfer -r --exclude 'knowledgebase/reference_proteomes' --exclude 'knowledgebase/taxonomic_divisions' 'fd9c190c-b824-11e9-98d7-0a63aa6b37da:/gridftp/pub/databases/uniprot/current_release/' '1ccc563b-0542-44e5-a13c-fc4b00281b72:/private_stores/mirror/uniprot/${FASTA_DIR}/



