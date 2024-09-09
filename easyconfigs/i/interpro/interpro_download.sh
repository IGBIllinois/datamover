# ----------------Load Modules--------------------
module load globus-cli/3.30.1-IGB-gcc-8.2.0-Python-3.10.1

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
globus transfer -r --exclude "reference_proteomes" --exclude "taxonomic_divisions" "47772002-3e5b-4fd3-b97c-18cee38d6df2:/pub/databases/interpro/releases/$VERSION/" "4a467fda-f559-4fc3-b54a-e2842f439e06:${MIRROR_DIR}/"


