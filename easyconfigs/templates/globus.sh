# ----------------Load Modules--------------------
module load globus-cli/3.18.0-IGB-gcc-8.2.0-Python-3.7.2

# ----------------Commands------------------------

if [ -z "$1" ];
then
	echo "Please specify version number";
	exit 1;
fi

VERSION=$1
DATABASE=""
MIRROR_DIR=/private_stores/mirror/${DATABASE}/${VERSION}
FASTA_DIR=${MIRROR_DIR}/db
BIOTRANSFER_UUID="1ccc563b-0542-44e5-a13c-fc4b00281b72"
SOURCE_UUID=""

echo "Downloading Files: `date "+%Y-%m-%d %k:%M:%S"`"
mkdir -p ${FASTA_DIR}
globus transfer -r "${SOURCE_UUID}:/pub/databases/uniprot/current_release/" "${PBIOTRANSFER_UUID}:${FASTA_DIR}/"



