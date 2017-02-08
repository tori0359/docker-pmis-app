FROM dev.sangah.com:5043/tomcat-base

COPY server.xml /usr/local/tomcat/conf/
RUN rm -rf /usr/local/tomcat/webapps/*
COPY stnd_pmis.war /usr/local/src/

VOLUME "/usr/local/tomcat/webapps"
#VOLUME "/edms"
#VOLUME "/usr/local/tomcat/logs"
#VOLUME "/var/log"
#VOLUME "/tmp"

EXPOSE 8080
EXPOSE 8081

# don't add anything else after this!
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
#CMD ["catalina.sh", "run"]