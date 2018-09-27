#!/bin/bash
idx=0;
iterations=$2
sleeptime=$1
# If we're in L1, let's measure vhost/qemu specifically
nestedlevel=$3

echo "Nested Level: L$3" 

while [ $idx -lt $iterations ]
do
  echo "--iteration $idx --"

  mpstat -I CPU
  iostat
  sar -A 1 1 

  idx=$[$idx+1]
  sleep $sleeptime

done
