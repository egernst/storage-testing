#!/bin/bash

tests=(randread randwrite)
iodepths=(1 2 4 8 16 32 1024)
resultsdir=$1

mkdir $resultsdir
for testtype in "${tests[@]}"; do
  for c in "${iodepths[@]}"; do

    jobs=$c
    if [ $c -gt "8" ]
    then 
  	jobs=8
    fi

    echo iterating: $testtype: queue $c, numjobs $jobs
    cmdargs="--size=8G --direct=1 --ioengine=libaio \
	--filename=/dev/nvme0n1 --overwrite=1 --readwrite=$testtype \
       	--bs=4K --runtime=180 --time_based --ramp_time=60 --invalidate=1 --norandommap --clocksource=cpu \
	--iodepth=$c --numjobs=$jobs  --name=iteration_$c"

    echo fio $cmdargs > $resultsdir/$testtype-q-$c-results.txt
    sudo fio  $cmdargs &>> $resultsdir/$testtype-q-$c-results.txt &
    fiopid=$!

    sleep 60
    ./measure.sh 4 20 > $resultsdir/$testtype-q-$c-measurements.log
    wait $fiopid
  done
done
