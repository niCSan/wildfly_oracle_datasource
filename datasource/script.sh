#!/bin/bash
# This script is originally made by user sepigh in Docker forums 
# Taken from https://forums.docker.com/t/docker-run-error-permission-denied-on-cmd-node-execure-sh/17129
# The only adjusted thing was the way to execute the jboss-cli commands
# The default mode is 'standalone' and default configuration is based on the
# mode. It can be 'standalone.xml' or 'domain.xml'.

echo "=> Executing Customization script"

JBOSS_HOME=/opt/jboss/wildfly
JBOSS_CLI=$JBOSS_HOME/bin/jboss-cli.sh
JBOSS_MODE=${1:-"standalone"}
JBOSS_CONFIG=${2:-"$JBOSS_MODE.xml"}

function wait_for_server() {
  until `$JBOSS_CLI -c ":read-attribute(name=server-state)" 2> /dev/null | grep -q running`; do
    sleep 1
  done
}

echo "=> Starting WildFly server"

echo "JBOSS_HOME  : " $JBOSS_HOME
echo "JBOSS_CLI   : " $JBOSS_CLI
echo "JBOSS_MODE  : " $JBOSS_MODE
echo "JBOSS_CONFIG: " $JBOSS_CONFIG

echo $JBOSS_HOME/bin/$JBOSS_MODE.sh -b 0.0.0.0 -c $JBOSS_CONFIG &
$JBOSS_HOME/bin/$JBOSS_MODE.sh -b 0.0.0.0 -c $JBOSS_CONFIG &

echo "=> Waiting for the server to boot"
wait_for_server

echo "=> Executing the commands"

# Add oracle driver to modules
$JBOSS_CLI -c --command="module add --name=com.oracle --resources=/opt/jboss/wildfly/ojdbc7.jar --dependencies=javax.api,javax.transaction.api"
# Add oracle driver to standalone.xml
$JBOSS_CLI -c --command="/subsystem=datasources/jdbc-driver=oracle:add(driver-name="oracle",driver-module-name="com.oracle",driver-class-name="oracle.jdbc.driver.OracleDriver",driver-xa-datasource-class-name="oracle.jdbc.xa.client.OracleXADataSource")"
# Add oracle datasource, more options to the datasource can be added
$JBOSS_CLI -c --command="/subsystem=datasources/data-source=oracleDS:add(driver-name="oracle",jndi-name="java:/jdbc/oracle",user-name="${USUARIO_BD}", password="${PASSWD_BD}",initial-pool-size="25", max-pool-size="50", min-pool-size="20",connection-url="${CONEXION_DB}")"

# Deploy the WAR
#cp /opt/jboss/wildfly/customization/leadservice-1.0.war $JBOSS_HOME/$JBOSS_MODE/deployments/leadservice-1.0.war

echo "=> Shutting down WildFly"
if [ "$JBOSS_MODE" = "standalone" ]; then
  $JBOSS_CLI -c ":shutdown"
else
  $JBOSS_CLI -c "/host=*:shutdown"
fi

echo "=> Restarting WildFly"
$JBOSS_HOME/bin/$JBOSS_MODE.sh -b 0.0.0.0 -c $JBOSS_CONFIG
