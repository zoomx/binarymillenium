#!/bin/bash

curl --silent http://10.1.2.12/now.jpg > intimages/nowbase.jpg

for i in `seq -w 1 5000`;
do
curl --silent http://10.1.2.12/now.jpg > intimages/now$i.jpg
./arlaser intimages/now$i.jpg intimages/nowbase.jpg
done
