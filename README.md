# wildfly_oracle_datasource
Docker image from Wildfly with oracle datasource and environment variables

This image is based on the script made by user sepigh in Docker forums Taken from https://forums.docker.com/t/docker-run-error-permission-denied-on-cmd-node-execure-sh/17129 The only adjusted thing was the way to execute the jboss-cli commands

The way to run this image is:

docker run -p 8080:8080 -e "USUARIO_BD=XXXUSER" -e "PASSWD_BD=XXXPWD" -e "CONEXION_DB=XXXCONN" nicsanitg/wildfly_oracle_datasource:latest

Where:

    XXXUSER: Is the oracle user from your DB
    XXXPWD: Is the password from the user
    XXXCONN: Is the jdbc connection starting with this format: "jdbc:oracle:thin:@"

This will append the environment variables to the datasource in the standalone.xml

Example:

docker run -p 8080:8080 -e "USUARIO_BD=scott" -e "PASSWD_BD=tiger" -e "CONEXION_DB=jdbc:oracle:thin:10.10.10.20:1521/HR" wildfly_oracle_datasource

