#!/bin/bash

mkdir $1
sudo ./run-rr.sh
sudo ./run-rw.sh
mv rr-q-* $1
mv rw-q-* $1
