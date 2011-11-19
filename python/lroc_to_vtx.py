# Lucas Walter November 18 2011 
# GNU GPL

import math
import array
import csv
import sys
import operator
import os

import Image, ImageFont, ImageDraw


filename = sys.argv[1]

sys.stderr.write("opening " + filename + '\n')

fraw = open(filename,'rb')

# TBD magic numbers from IMG header
offset = 0x1680/2

bindat = array.array('h')

bindat.fromfile(fraw, offset)

# TBD magic numbers from IMG header
size = 1440, 720
sub_size = size #1440, 2
im = Image.new("F", sub_size)
pix = im.load()

count = 0

while(True and count < sub_size[1]):
  bindat = array.array('h')
  try:
    bindat.fromfile(fraw, size[0])
  except:
    break

  #if sys.byteorder == "little":
  #    bindat.byteswap()

  latitude = count

  max_elev = 0;
  min_elev = 0;
  for i in range(sub_size[0]):
    elev = bindat[i]
    if (elev < min_elev):
      min_elev = elev
    if (elev > max_elev):
      max_elev = elev

    r = (elev+32768)/65535.0
       
    pix[i,count] = r*255.0 
  
  if (count%100 == 0):
    sys.stderr.write(str(count) + ' row size ' + str(len(bindat)) + '\t' + str(min_elev) + '\t' + str(max_elev) + '\n')
  count = count + 1

if False:
  im.show()
  im.save("moon.tif", "TIFF")

# TBD magic numbers from IMG header
base_elev = 1737400.0 - math.pow(2,15)
scale = 100000.0

num_verts = sub_size[0] * sub_size[1]

num_faces = (sub_size[0]) * (sub_size[1]-1) * 2
#num_faces = 0

sys.stderr.write('num_faces ' + str(num_faces) + ' num_verts ' + str(num_verts) + '\n')

header = """ply
format ascii 1.0
element vertex """
header = header + str(num_verts)
header = header + """
property float x
property float y
property float z
property uchar red
property uchar green
property uchar blue
element face """
header = header + str(num_faces)
header = header + """
property list uchar int vertex_indices
end_header
"""

sys.stdout.write(header)

sys.stderr.write('outputting ply\n')

for j in range(sub_size[1]):
  for i in range(sub_size[0]):
    elev = pix[i,j];
    longitude = 2.0*math.pi*i/float(size[0])
    latitude = math.pi*j/float(size[1]) - math.pi/2
    radius = base_elev + elev/255.0 * math.pow(2,16)
    
    x = radius/scale * math.cos(latitude) * math.cos(longitude)
    y = radius/scale * math.cos(latitude) * math.sin(longitude)
    z = radius/scale * math.sin(latitude)
    
    es = str(int(elev))
    col = es + ' ' + es + ' ' + es  
    sys.stdout.write(str(x) + ' ' + str(y) + ' ' + str(z) + ' ' + col + '\n')

sys.stderr.write('finished vertices\n')


face_count = 0
for j in range(sub_size[1] - 1):
  for i in range(sub_size[0] - 1):
    base_ind = j*sub_size[0] + i  
    # TBD need to reverse facing
    
    ind1 = base_ind + sub_size[0]
    ind2 = base_ind + 1
    ind3 = base_ind
    ind4 = base_ind + sub_size[0] + 1

    sys.stdout.write('3 ' + str(ind3) + ' ' + str(ind2) + ' ' + str(ind1) + '\n') 
    sys.stdout.write('3 ' + str(ind2) + ' ' + str(ind4) + ' ' + str(ind1) + '\n') 
    face_count += 2
   

# size = 5,2
#   0---1  2  3  4   0
#   | / |
#   5---6  7  8  9   5
#
#   0 1 5        4 0 9
#   1 6 5        0 5 9


if (sub_size[0] == size[0]):
  sys.stderr.write('connecting loop\n')

  #sys.stdout.write('#\n')
  i = sub_size[0] - 1
  for j in range(sub_size[1] - 1):
    base_ind = j * sub_size[0] + i

    ind1 = base_ind + sub_size[0]
    ind2 = base_ind + 1 - sub_size[0]
    ind3 = base_ind
    ind4 = base_ind + 1

    sys.stdout.write('3 ' + str(ind3) + ' ' + str(ind2) + ' ' + str(ind1) + '\n') 
    sys.stdout.write('3 ' + str(ind2) + ' ' + str(ind4) + ' ' + str(ind1) + '\n') 
    
    face_count += 2
   

sys.stderr.write('done ' + str(count) + ' ' + str(face_count) + '\n')
