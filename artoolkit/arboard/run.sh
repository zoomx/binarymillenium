#!/bin/bash

#base="/media/NIKON D4OX/DCIM/100ND40X/arlidar_first"
base=../frames3

for i in $base/output*png; do 
echo $i
./arlaser "$i" 
done
