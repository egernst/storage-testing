#!/bin/bash 


iodepths=(1 2 4 8 16 32 1024)

for c in "${iodepths[@]}"; do

  jobs=$c
  if [ $c -gt "8" ]
  then 
	jobs=8
  fi

  echo iterating: queue $c, numjobs $jobs
  
  sudo fio  --size=8G --direct=1 --ioengine=libaio \
	--filename=/dev/nvme0n1 --overwrite=1 --readwrite=randread \
       	--bs=4K --runtime=180 --time_based --ramp_time=60 --invalidate=1 --clocksource=clock_gettime \
	--iodepth=$c --numjobs=$jobs  --name=iteration_$c &> rr-q-$c-results.txt &
  fiopid=$!

  echo goign to sleep for a bit
  sleep 60
  echo "yawn, let's wait for pid $ifopid to finish"
  ./measure.sh 4 20 > rr-q-$c-measurements.log
  wait $fiopid
  echo "done"
done
