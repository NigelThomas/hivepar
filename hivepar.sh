#!/bin/bash
#
# start a development container, load all slab files from the current project

HERE=$(cd `dirname $0`; pwd)
BASE_IMAGE=sqlstream/streamlab-git
: ${CONTAINER_NAME:=hivepar}

# This is a SQL project - there are no SLAB files
: ${LOAD_SLAB_FILES:=}

GIT_ACCOUNT=https://github.com/NigelThomas
GIT_PROJECT_NAME=hivepar

# default image label is latest 6.0.1 (:release)
: ${BASE_IMAGE_LABEL:=release}

docker kill $CONTAINER_NAME
docker rm $CONTAINER_NAME

# mount the custom JNDI directory if needed (else we use the git repo's jndi directory
# note: you may use the project's own jndi directory in which case working copies of properties files will override committed/pushed copies

if [ -n "$HOST_JNDI_DIR" ]
then
    HOST_JNDI_MOUNT="-v ${HOST_JNDI_DIR:=$HERE/jndi}:$CONTAINER_JNDI_DIR"
fi

if [ -n "$HOST_OUTPUT_DIR" ]
then
    if [ ! -d $HOST_OUTPUT_DIR ]
    then
        mkdir -p $HOST_OUTPUT_DIR
    else
        rm -rf $HOST_OUTPUT_DIR
        mkdir -p $HOST_OUTPUT_DIR
    fi

    HOST_OUTPUT_MOUNT="-v ${HOST_OUTPUT_DIR}:${CONTAINER_OUTPUT_DIR:=/home/sqlstream/output}"
else
    HOST_OUTPUT_MOUNT=
fi


# override default host mount point for credentials using HOST_CRED_MOUNT

docker run $HOST_JNDI_MOUNT $HOST_OUTPUT_MOUNT \
           -v ${HOST_CRED_MOUNT:=$HOME/credentials}:/home/sqlstream/credentials \
           -e GIT_ACCOUNT=$GIT_ACCOUNT -e GIT_PROJECT_NAME=$GIT_PROJECT_NAME -e GIT_PROJECT_HASH=$GIT_PROJECT_HASH \
           -e LOAD_SLAB_FILES="${LOAD_SLAB_FILES:=}" \
           -e SQLSTREAM_HEAP_MEMORY=${SQLSTREAM_HEAP_MEMORY:=4096m} \
           -e SQLSTREAM_SLEEP_SECS=${SQLSTREAM_SLEEP_SECS:=5} \
           -d --name $CONTAINER_NAME --hostname $CONTAINER_NAME -it $BASE_IMAGE:$BASE_IMAGE_LABEL

#docker logs -f $CONTAINER_NAME
