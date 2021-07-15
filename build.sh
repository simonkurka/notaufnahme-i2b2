#!/bin/bash
set -e

PACKAGE=aktin-notaufnahme-i2b2
VI2B2=1.7.12a
VI2B2_WEBCLIENT=1.7.12a.0002
VPOSTGRES_JDBC=42.2.8
VWILDFLY=18.0.0.Final

DBUILD=$1

# Directory this script is located in + /resources
DRESOURCES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/resources"

mkdir -p $DBUILD

#
# Download i2b2 webclient
#
mkdir -p $DBUILD/var/www/html
wget https://github.com/i2b2/i2b2-webclient/archive/v$VI2B2_WEBCLIENT.zip -P $DBUILD
unzip $DBUILD/v$VI2B2_WEBCLIENT.zip -d $DBUILD/var/www/html
rm $DBUILD/v$VI2B2_WEBCLIENT.zip
mv $DBUILD/var/www/html/i2b2-webclient-$VI2B2_WEBCLIENT $DBUILD/var/www/html/webclient

sed -i 's|name: \"HarvardDemo\",|name: \"AKTIN\",|' $DBUILD/var/www/html/webclient/i2b2_config_data.js
sed -i 's|urlCellPM: \"http://services.i2b2.org/i2b2/services/PMService/\",|urlCellPM: \"http://127.0.0.1:9090/i2b2/services/PMService/\",|' $DBUILD/var/www/html/webclient/i2b2_config_data.js
sed -i 's|loginDefaultUsername : \"demo\"|loginDefaultUsername : \"\"|' $DBUILD/var/www/html/webclient/js-i2b2/i2b2_ui_config.js
sed -i 's|loginDefaultPassword : \"demouser\"|loginDefaultPassword : \"\"|' $DBUILD/var/www/html/webclient/js-i2b2/i2b2_ui_config.js

#
# Create apache2 proxy configuration
#
mkdir -p $DBUILD/etc/apache2/conf-available
cp $DRESOURCES/aktin-j2ee-reverse-proxy.conf $DBUILD/etc/apache2/conf-available/aktin-j2ee-reverse-proxy.conf

#
# Download wildfly
#
wget https://download.jboss.org/wildfly/$VWILDFLY/wildfly-$VWILDFLY.zip -P $DBUILD
unzip $DBUILD/wildfly-$VWILDFLY.zip -d $DBUILD/opt
rm $DBUILD/wildfly-$VWILDFLY.zip
mv $DBUILD/opt/wildfly-* $DBUILD/opt/wildfly

#
# Setup wildfly systemd service
#
mkdir -p $DBUILD/lib/systemd/system $DBUILD/var/lib/aktin $DBUILD/etc/wildfly
cp $DBUILD/opt/wildfly/docs/contrib/scripts/systemd/wildfly.service $DBUILD/lib/systemd/system/
cp $DBUILD/opt/wildfly/docs/contrib/scripts/systemd/wildfly.conf $DBUILD/etc/wildfly/
cp $DBUILD/opt/wildfly/docs/contrib/scripts/systemd/launch.sh $DBUILD/opt/wildfly/bin/

#
# Customize wildfly
#
echo JBOSS_HOME=\"/opt/wildfly\" >> $DBUILD/etc/wildfly/wildfly.conf
echo JBOSS_OPTS=\"-Djboss.http.port=9090 -Djrmboss.as.management.blocking.timeout=6000\" >> $DBUILD/etc/wildfly/wildfly.conf

sed -i 's/-Xms64m -Xmx512m/-Xms1024m -Xmx2g/' $DBUILD/opt/wildfly/bin/appclient.conf
sed -i 's/-Xms64m -Xmx512m/-Xms1014m -Xmx2g/' $DBUILD/opt/wildfly/bin/standalone.conf
sed -i 's|<rotate-size value="50m"/>|<rotate-size value="1g"/>|' $DBUILD/opt/wildfly/bin/standalone.conf

patch -p1 -d $DBUILD/opt/wildfly < $DRESOURCES/standalone.xml.patch

wget https://www.aktin.org/software/repo/org/i2b2/$VI2B2/i2b2.war -P $DBUILD/opt/wildfly/standalone/deployments/
wget https://jdbc.postgresql.org/download/postgresql-$VPOSTGRES_JDBC.jar -P $DBUILD/opt/wildfly/standalone/deployments/

cp $DRESOURCES/datasource/* $DBUILD/opt/wildfly/standalone/deployments/

#
# Post-install resources
#
mkdir -p $DBUILD/usr/share/$PACKAGE
cp -r $DRESOURCES/database $DBUILD/usr/share/$PACKAGE/

