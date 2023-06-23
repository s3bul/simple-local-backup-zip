#!/usr/bin/env bash

if [ -z "${SCRIPT_FILE_PATH}" ]; then
  echo "You must set \"SCRIPT_FILE_PATH\" variable"
  exit 1
fi
if [ ! -d "${SCRIPT_FILE_PATH}" ]; then
  echo "Directory \"${SCRIPT_FILE_PATH}\" doesn't exists"
  exit 1
fi

scriptPath=$(realpath $(dirname "$0"))
zipPath=${SCRIPT_ZIP_PATH:-${scriptPath}}

if [ ! -d "${zipPath}" ]; then
  echo "Directory \"${zipPath}\" doesn't exists"
  exit 1
fi

date=$(date +%Y%m%d%H%M%S)
lastZip=$(ls -t "${zipPath}"/*.zip | head -n 1)
modsecs=$(date --utc --reference ${lastZip} +%s)
nowsecs=$(date +%s)
delta=$((${nowsecs}-${modsecs}))
logDate=$(date +"%Y-%m-%d %H:%M:%S")

echo "[${logDate}] Start backup"

if [ ${delta} -gt ${SCRIPT_CHECK_SECONDS:-3600} ]; then
  zip -jTDr "${zipPath}/backup-${date}.zip" "${SCRIPT_FILE_PATH}"
else
  echo "File ${lastZip} was modified ${delta} secs ago"
fi

rm -vf $(find "${zipPath}" -type f -name "*.zip" -mtime ${SCRIPT_ZIP_OLD_DAYS:-30} | head -n 1)
