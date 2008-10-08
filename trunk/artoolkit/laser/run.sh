#!/bin/bash

base=intimages
#base="/media/sda1/cygwin/home/lucasw/lidlaser/fidlaser"

for i in $base/now0*jpg; do 
#echo $i
./arlaser $i $base/now0001.jpg
#echo "./arlaser $base/fl_000$i.jpg $base/fl_000020.jpg "
done
#./arlaser images/fl_000200.jpg
