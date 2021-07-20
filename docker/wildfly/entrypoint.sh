#!/bin/bash
echo "Setting datasources ..." && \
find /usr/share/aktin-notaufnahme-i2b2/datasource -name '*.xml' -exec bash -c "sed -e \"s/__HOST__/${DBHOST}/g\" -e \"s/__PORT__/${DBPORT}/g\" \$0 > /opt/jboss/wildfly/standalone/deployments/\$(basename -- \$0)" {} \; && \
echo "Datasources set! Starting wildfly ..." && \
/opt/jboss/wildfly/bin/standalone.sh -b 0.0.0.0

