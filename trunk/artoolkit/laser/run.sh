#!/bin/bash

base=images
#base="/media/sda1/cygwin/home/lucasw/lidlaser/fidlaser"

for i in `seq -w 33 1127`; do 
#echo $i
./arlaser $base/fl3_00$i.jpg $base/fl3_000015.jpg
#echo "./arlaser $base/fl_000$i.jpg $base/fl_000020.jpg "
done
#./arlaser images/fl_000200.jpg
