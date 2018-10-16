#!/bin/bash
set -e

echo 0 >  /sys/block/sdc/queue/rq_affinity 

/usr/bin/fio "$@"
