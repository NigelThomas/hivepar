tdir=test-`date +"%Y.%m.%d-%H.%M"`
mkdir $tdir

if [ -n "$2" ]
then
    # we are going to use the local file system for temp output files
    HOST_OUTPUT_STYLE="mounted volume"
else
    HOST_OUTPUT_STYLE="docker layer"
    HOST_OUTPUT_DIR=
fi

    
for p in `seq -w 1 $1`
do
    export CONTAINER_NAME=hivepar$p
    if [ "${HOST_OUTPUT_STYLE}" = "mounted volume" ]
    then
        # we are going to use the local file system for temp output files
        export HOST_OUTPUT_DIR=`pwd`/${CONTAINER_NAME}
    fi
    echo "starting $CONTAINER_NAME" 
    ./hivepar.sh
done

cd $tdir

echo "hivepar-parallel with $1 containers started at `date` using ${HOST_OUTPUT_STYLE} logging to $tdir" | tee > summary.txt

# stats every 15 secs for 25 minutes with timestamp and wide format
vmstat -t -w 15 100 | tee vmstat.log

for p in `seq -w 1 $1`
do
    export CONTAINER_NAME=hivepar$p
    # collect trace log and stream stats
    docker cp ${CONTAINER_NAME}:/var/log/sqlstream/Trace.log.0 ${CONTAINER_NAME}.trace.log

    # some analyis on the logs
    # .. extract flushes in the format "rows HH:MM:SS"
    grep flushing ${CONTAINER_NAME}.trace.log | \
         sed -e "s/.*flushing //" -e "s/ rows.*INFO \[/ /" -e "s/]: com.*//" | \
         awk '{printf "%s %05d\n",$4,$1}' | cut -c1-11 > ${CONTAINER_NAME}.flush.log

    docker cp ${CONTAINER_NAME}:/home/sqlstream/monitor/edr_minute_count-${CONTAINER_NAME}.csv .
done

echo Test $tdir completed at `date` | tee >>summary.txt
# Keep a running summary in the next level up
cat summary.txt >> ../test-summary.txt

cd ..
pwd



