#!/bin/bash
set -e

# Required parameters
PACKAGE="${1}"
VERSION="${2}"

# Optional parameter
FULL="${3}"

# Check if variables are empty
if [ -z "${PACKAGE}" ]; then echo "\$PACKAGE is empty."; exit 1; fi
if [ -z "${VERSION}" ]; then echo "\$VERSION is empty."; exit 1; fi

# Directory this script is located in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DBUILD="${DIR}/build"

# Cleanup
rm -rf "${DIR}/build"

export I2B2IMAGENAMESPACE="$(echo "${PACKAGE}" | awk -F '-' '{print "ghcr.io/"$1"/"$2"-i2b2-"}')"
export DWHIMAGENAMESPACE="$(echo "${PACKAGE}" | awk -F '-' '{print "ghcr.io/"$1"/"$2"-dwh-"}')"

# Load common linux files
. "$(dirname "${DIR}")/build.sh"

mkdir -p "${DBUILD}/wildfly"
sed -e "s/__VWILDFLY__/${VWILDFLY}/g" "${DIR}/wildfly/Dockerfile" >"${DBUILD}/wildfly/Dockerfile"
cp "${DIR}/wildfly/entrypoint.sh" "${DBUILD}/wildfly/"
cp "${DRESOURCES}/standalone.xml.patch" "${DBUILD}/wildfly/"
wildfly_i2b2 "/wildfly"
datasource_postinstall "/wildfly/ds"

mkdir -p "${DBUILD}/database"
cp "${DIR}/database/Dockerfile" "${DBUILD}/database/"
database_postinstall "/database/sql"
cat "${DBUILD}/database/sql/i2b2_postgres_init.sql" >"${DBUILD}/database/sql/00_init.sql"
cat "${DBUILD}/database/sql/i2b2_db.sql" >>"${DBUILD}/database/sql/00_init.sql"

mkdir -p "${DBUILD}/httpd"
cp "${DIR}/httpd/Dockerfile" "${DBUILD}/httpd/"
i2b2_webclient "/httpd/i2b2webclient"
apache2_proxy "/httpd" "wildfly"

if [ "${FULL}" = "full" ]; then
	cwd="$(pwd)"
	cd "${DIR}"
	docker-compose build
	cd "${cwd}"
fi

