#!/bin/bash
#python ./bin_to_csv.py "flower/pointsred_0_0.bin" points_0_0.csv 
#

#python ./bin_to_csv.py "some/points_0_1.bin" points_0_1.csv 

for i in `seq 0 23`
do 
	#echo "python ./bin_to_csv.py some/points_0_$i.bin" 
	 ./bin_to_csv.py "boxer/points_0_$i.bin"  
done
