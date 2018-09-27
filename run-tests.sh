#!/bin/bash

mkdir $1
sudo ./run-rr.sh
sudo ./run-rw.sh
mv r.-q-* $1
