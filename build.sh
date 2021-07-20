#!/bin/bash
set -e

# Check if variables are empty
if [ -z "${PACKAGE}" ]; then echo "\$PACKAGE is empty."; exit 1; fi
if [ -z "${VERSION}" ]; then echo "\$VERSION is empty."; exit 1; fi
if [ -z "${DBUILD}" ]; then echo "\$DBUILD is empty."; exit 1; fi

# Directory this script is located in + /resources
DRESOURCES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/resources"

set -a
. "${DRESOURCES}/versions"
set +a

mkdir -p "${DBUILD}"

function i2b2_webclient() {
	DWEBCLIENT="${1}"

	wget "https://github.com/i2b2/i2b2-webclient/archive/v${VI2B2_WEBCLIENT}.zip" -P "${DBUILD}"
	unzip "${DBUILD}/v${VI2B2_WEBCLIENT}.zip" -d "${DBUILD}"
	rm "${DBUILD}/v${VI2B2_WEBCLIENT}.zip"
	mkdir -p "$(dirname "${DBUILD}${DWEBCLIENT}")"
	mv "${DBUILD}/i2b2-webclient-${VI2B2_WEBCLIENT}" "${DBUILD}${DWEBCLIENT}"

	sed -i 's|name: \"HarvardDemo\",|name: \"AKTIN\",|' "${DBUILD}${DWEBCLIENT}/i2b2_config_data.js"
	sed -i 's|urlCellPM: \"http://services.i2b2.org/i2b2/services/PMService/\",|urlCellPM: \"http://127.0.0.1:9090/i2b2/services/PMService/\",|' "${DBUILD}${DWEBCLIENT}/i2b2_config_data.js"
	sed -i 's|loginDefaultUsername : \"demo\"|loginDefaultUsername : \"\"|' "${DBUILD}${DWEBCLIENT}/js-i2b2/i2b2_ui_config.js"
	sed -i 's|loginDefaultPassword : \"demouser\"|loginDefaultPassword : \"\"|' "${DBUILD}${DWEBCLIENT}/js-i2b2/i2b2_ui_config.js"
}

function apache2_proxy() {
	DAPACHE2CONF="${1}"
	WILDFLYHOST="${2}"

	mkdir -p "${DBUILD}${DAPACHE2CONF}"
	sed -e "s/__WILDFLYHOST__/${WILDFLYHOST}/g" "${DRESOURCES}/aktin-j2ee-reverse-proxy.conf" >"${DBUILD}${DAPACHE2CONF}/aktin-j2ee-reverse-proxy.conf"
}

function wildfly_download() {
	DWILDFLYHOME="$1"

	wget "https://download.jboss.org/wildfly/${VWILDFLY}/wildfly-${VWILDFLY}.zip" -P "${DBUILD}"
	unzip "${DBUILD}/wildfly-${VWILDFLY}.zip" -d "${DBUILD}"
	rm "${DBUILD}/wildfly-${VWILDFLY}.zip"
	mkdir -p "$(dirname "${DBUILD}${DWILDFLYHOME}")"
	mv "${DBUILD}/wildfly-${VWILDFLY}" "${DBUILD}${DWILDFLYHOME}"
}

function wildfly_systemd() {
	DWILDFLYHOME="$1"
	DWILDFLYCONFIG="$2"
	DSYSTEMD="$3"

	mkdir -p "${DBUILD}${DWILDFLYCONFIG}" "${DBUILD}${DSYSTEMD}"
	cp "${DBUILD}${DWILDFLYHOME}/docs/contrib/scripts/systemd/wildfly.service" "${DBUILD}${DSYSTEMD}/"
	cp "${DBUILD}${DWILDFLYHOME}/docs/contrib/scripts/systemd/wildfly.conf" "${DBUILD}${DWILDFLYCONFIG}/"
	cp "${DBUILD}${DWILDFLYHOME}/docs/contrib/scripts/systemd/launch.sh" "${DBUILD}${DWILDFLYHOME}/bin/"
}

function wildfly_config() {
	DWILDFLYHOME="$1"
	DWILDFLYCONFIG="$2"

	echo "JBOSS_HOME=\"${DWILDFLYHOME}\"" >> "${DBUILD}${DWILDFLYCONFIG}/wildfly.conf"
	echo "JBOSS_OPTS=\"-Djboss.http.port=9090 -Djrmboss.as.management.blocking.timeout=6000\"" >> "${DBUILD}${DWILDFLYCONFIG}/wildfly.conf"

	sed -i 's/-Xms64m -Xmx512m/-Xms1024m -Xmx2g/' "${DBUILD}${DWILDFLYHOME}/bin/appclient.conf"
	sed -i 's/-Xms64m -Xmx512m/-Xms1014m -Xmx2g/' "${DBUILD}${DWILDFLYHOME}/bin/standalone.conf"

	patch -p1 -d "${DBUILD}${DWILDFLYHOME}" < "${DRESOURCES}/standalone.xml.patch"
}

function wildfly_i2b2() {
	DWILDFLYDEPLOYMENTS="$1"

	wget "https://www.aktin.org/software/repo/org/i2b2/${VI2B2}/i2b2.war" -P "${DBUILD}${DWILDFLYDEPLOYMENTS}"
	wget "https://jdbc.postgresql.org/download/postgresql-${VPOSTGRES_JDBC}.jar" -P "${DBUILD}${DWILDFLYDEPLOYMENTS}"
}

function database_postinstall() {
	DDBPOSTINSTALL="$1"

	mkdir -p "$(dirname "${DBUILD}${DDBPOSTINSTALL}")"
	cp -r "${DRESOURCES}/database" "${DBUILD}${DDBPOSTINSTALL}"
}

function datasource_postinstall() {
	DDSPOSTINSTALL="$1"

	mkdir -p "$(dirname "${DBUILD}${DDSPOSTINSTALL}")"
	cp -r "${DRESOURCES}/datasource" "${DBUILD}${DDSPOSTINSTALL}"
}

function build_linux() {
	i2b2_webclient "/var/www/html/webclient"
	apache2_proxy "/etc/apache2/conf-available" "localhost"
	wildfly_download "/opt/wildfly"
	wildfly_systemd "/opt/wildfly" "/etc/wildfly" "/lib/systemd/system"
	wildfly_config "/opt/wildfly" "/etc/wildfly"
	wildfly_i2b2 "/opt/wildfly/standalone/deployments"
	database_postinstall "/usr/share/${PACKAGE}/database"
	datasource_postinstall "/usr/share/${PACKAGE}/datasource"
}

