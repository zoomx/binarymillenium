#!/bin/bash

for i in `seq -w 0 10000`; 
do
   
    curl "http://192.168.1.57/now.jpg" > image\_$i.jpg;

done;

