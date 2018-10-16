#!/bin/bash

runtime=(kata-runtime runc)
tests=(randread randwrite)
iodepths=(1 2 4 8 16 32 1024)
resultsdir=$1
ramptime=10
runlength=35
disk="/dev/sdc"
mkdir $resultsdir
for runtimeType in "${runtime[@]}"; do
	for testtype in "${tests[@]}"; do
		for c in "${iodepths[@]}"; do

			jobs=$c
			if [ $c -gt "8" ]
			then 
				jobs=8
			fi

			echo iterating: $testtype: queue $c, numjobs $jobs

			if [ $runtimeType == "runc" ]
			then
				runcCPUs="--cpus=8"

			else
				runcCPUS=""
			fi		
			if [ $runtimeType == "native" ]
			then
				dockerCmd=""
			else
				dockerCmd="docker run --runtime=$runtimeType $runcCPUs --device $disk --privileged -itd "
			fi


			cmdargs="--size=8G --ioengine=libaio \
				--filename=$disk --overwrite=1 --readwrite=$testtype \
				--runtime=$runlength --time_based --ramp_time=$ramptime --norandommap --clocksource=cpu \
				--bs=16k --iodepth=$c --numjobs=1 --sync=1 --invalidate=1 --direct=1 \
				--name=iteration_$c"

			echo $dockerCmd fio $cmdargs > $resultsdir/$runtimeType-$testtype-q-$c-results.txt
			#sudo docker run --runtime=$runtimeType -it fio  $cmdargs &>> $resultsdir/$testtype-q-$c-results.txt

			sudo $dockerCmd fio $cmdargs &>> $resultsdir/$runtimeType-$testtype-q-$c-results.txt 

			fiopid=$!

			sleep $ramptime
			sar -d -r -u 3 8 > $resultsdir/$runtimeType-$testtype-q-$c-measurements.log
			sarpid=$!


			###
			# Need to drop the caches periodically to createa more fair comparison.  I think
			##	
			idx=0;
			sleeptime=2	
			iterations=14
			while [ $idx -lt $iterations ]
			do
				sync &>/dev/null && echo 3 | sudo tee /proc/sys/vm/drop_caches &> /dev/null
				idx=$[$idx+1]
				sleep $sleeptime
			done
			wait $sarpid
			wait $fiopid
		done
	done
done
