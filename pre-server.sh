# Install the repro case
#
# Assumes we are running in a docker container (eg sqlstream/minimal:release) as root (no need for sudo)

. /etc/sqlstream/environment

# assume credentials are mounted at /home/sqlstream/credentials
CRED=/home/sqlstream/credentials

. $CRED/install_credentials.sh
