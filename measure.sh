#!/bin/bash
idx=0;
iterations=$2
sleeptime=$1


while [ $idx -lt $iterations ]
do
  echo "--iteration $idx --"

  mpstat -I CPU
  sar -A 1 1 

  idx=$[$idx+1]
  sleep $sleeptime

done
