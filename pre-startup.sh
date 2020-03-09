#!/bin/bash
#
# Do any preproject setup needed before loading the StreamLab projects
#
# Assume we are running in the project directory
. /etc/sqlstream/environment

mkdir -p $SQLSTREAM_HOME/classes/net/sf/farrago/dynamic/

echo ... installing the SQLstream schema 
# update setup.sql to replace placeholders with actual values
echo ... running on host=`hostname`
sed -i -e "s/%HOSTNAME%/`hostname`/g" setup.sql

$SQLSTREAM_HOME/bin/sqllineClient --run=setup.sql




