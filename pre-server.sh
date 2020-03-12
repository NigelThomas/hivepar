# Install the repro case
#
# Assumes we are running in a docker container (eg sqlstream/minimal:release) as root (no need for sudo)

. /etc/sqlstream/environment

cat >> /var/log/sqlstream/Trace.properties <<!END
com.sqlstream.aspen.namespace.hive.level=FINE 
com.sqlstream.aspen.namespace.hdfs.level=FINE 
com.sqlstream.aspen.namespace.orc.level=FINE
!END

# assume credentials are mounted at /home/sqlstream/credentials
CRED=/home/sqlstream/credentials

. $CRED/install_credentials.sh
