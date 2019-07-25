FROM jboss/wildfly:10.1.0.Final

MAINTAINER "nicolassantisteban@gmail.com"

ADD datasource/script.sh /opt/jboss/wildfly
ADD datasource/ojdbc7.jar /opt/jboss/wildfly

CMD ["/opt/jboss/wildfly/script.sh"]
