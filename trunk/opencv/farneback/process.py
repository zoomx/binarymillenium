import os
import glob

i = 0
files = glob.glob( '../*.png' )
files.sort()

print files

for i in range(len(files)-1):
  print "#", files[i]
  print 'fback', files[i], files[i+1], 'forward-lambda20.00_' + str(i) + '-' + str(i+1) + '.sVflow', 'for'+str(i) + '.png'
  print 'fback', files[i+1], files[i], 'backward-lambda20.00_' + str(i+1) + '-' + str(i) + '.sVflow', 'bak'+str(i) + '.png'
print "#"
