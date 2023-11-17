# ----------------Load Modules--------------------
module load globus-cli/3.18.0-IGB-gcc-8.2.0-Python-3.7.2

# ----------------Commands------------------------

if [ -z "$1" ];
then
	echo "Please specify ena version number";
	exit 1;
fi

VERSION=$1
MIRROR_DIR=/private_stores/mirror/ena/${VERSION}

echo "Downloading Files: `date "+%Y-%m-%d %k:%M:%S"`"
#mkdir -p ${MIRROR_DIR}
#mkdir ${MIRROR_DIR}/wgs
#mkdir ${MIRROR_DIR}/sequence

globus transfer --preserve-timestamp --skip-source-errors --delete -r "47772002-3e5b-4fd3-b97c-18cee38d6df2:/pub/databases/ena/wgs/" "1ccc563b-0542-44e5-a13c-fc4b00281b72:${MIRROR_DIR}/wgs/"
globus transfer --preserve-timestamp --skip-source-errors --delete -r "47772002-3e5b-4fd3-b97c-18cee38d6df2:/pub/databases/ena/sequence/snapshot_latest/" "1ccc563b-0542-44e5-a13c-fc4b00281b72:${MIRROR_DIR}/sequence/"




