import sys
import array
import Image

filename = sys.argv[1]
fraw = open(filename,'rb')
fbin = array.array('i')


fbin.fromfile(fraw, 4)
#print fbin

width = fbin[2]
height = fbin[3]

print 'width', width, ', height', height

#fpng = open(filename + '.png', 'wb')
#wpng = png.Writer(width, height )
im = Image.new("RGB", (width, height))

x = 0
y = 0

s = []

while True:
  fbin = array.array('f')

  try:
    fbin.fromfile(fraw, 2)
  except:
    break
  
  dx = fbin[0]
  dy = fbin[1]
  #print x, y, dx, dy

  r = ( int((dx)*64 + 128))
  g = ( int((dy)*64 + 128))
  b = (128)
  im.putpixel( (x,y), (r,g,b) )

  x+= 1
  if (x ==width):
    x = 0
    y += 1

im.save(filename + '.png', "PNG")
