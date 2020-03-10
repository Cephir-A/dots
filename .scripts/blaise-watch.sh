#!/bin/bash
BLAISE_DIR="${BLAISE_ROOT}"

if [ ! -z "$2" ] 
then
  BLAISE_DIR="$2"
fi

if [ -z "${BLAISE_DIR}" ]
then
  echo "Please provide your working directory, either as an arguement, or with the BLAISE_ROOT env variable."
  exit 1
fi

# This is the Blaise Core Web directory. Adjust to you real path.
CORE_WEB="${BLAISE_DIR}/blaise-core/blaise-web/web"

# Please note no / at the end of paths!
case $1 in
    hd)
    TARGET="${BLAISE_DIR}/hd-blaise/hd-blaise-web/target/tmp"
    ;;
    # Add more options here...
    jcb)
    TARGET="${BLAISE_DIR}/jcb-blaise/jcb-blaise-web/target/tmp"
    ;;
    wb)
    TARGET="${BLAISE_DIR}/blaise-core/blaise-whitelabel-web/target/tmp"
    ;;
    *)
    echo "Unknown option: please ose one of the following: hd, jcb, wb."
    exit 1
    ;;
esac

#Check os due to difference between OSX and GNU find.
OS=`uname -a | grep Linux`

if [ ! -z "${OS}" ]
then
  TARGET=`find ${TARGET} -maxdepth 1 -name "*cognitran-cms-1*"`
else
  TARGET=`find ${TARGET} -name "*cognitran-cms-1*" -d 1`
fi
echo "Found core web folder @ \"${TARGET}\"."

echo "Synchronising \"${CORE_WEB}\" -> \"${TARGET}\"..."
echo -e "Press Ctrl+C to stop.\n\n"

while true; do
    # Sync JSPs
    rsync --out-format='updating %n' -r --update "${CORE_WEB}/WEB-INF/jsp" "${TARGET}/WEB-INF" 
    # Sync resources
    rsync --out-format='updating %n' -r --update "${CORE_WEB}/resources" "${TARGET}" 
    # Sync tags
    rsync --out-format='updating %n' -r --update "${CORE_WEB}/WEB-INF/tags" "${TARGET}/WEB-INF" 
    sleep 1
done
