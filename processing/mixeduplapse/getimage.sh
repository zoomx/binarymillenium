#!/bin/bash

for i in `seq -w 0 10000`; 
do
   
    curl "http://192.168.2.57/now.jpg" > src/image\_$i.jpg;

done;

