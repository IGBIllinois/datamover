# ----------------Load Modules--------------------
module load globus-cli/3.18.0-IGB-gcc-8.2.0-Python-3.7.2

DATABASE="interpro"

if [ -z "$1" ];
then
	echo "Please specify ${DATABASE} version number";
	exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/${DATABASE}/${VERSION}

echo "`date "+%Y-%m-%d %k:%M:%S"` Downloading Files"
mkdir -p ${MIRROR_DIR}
globus transfer -r --exclude "reference_proteomes" --exclude "taxonomic_divisions" "47772002-3e5b-4fd3-b97c-18cee38d6df2:/pub/databases/interpro/releases/$VERSION/" "1ccc563b-0542-44e5-a13c-fc4b00281b72:${MIRROR_DIR}/"


