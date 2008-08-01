import math
import array
import csv
import sys

def processBin1206(bin,outfile, rot,vert,dist,z_off,x_off):

	#output = array.array('f')
	
	for i in range(12):
		new_rot = (bin[i*100+3]*255 + bin[i*100+2])/100.0
	
		lower_not_upper = -1;
		if bin[i*100+1] == 238: lower_not_upper = 0;   # EE upper
		if bin[i*100+1] == 221: lower_not_upper = 1;   # DD lower

		if lower_not_upper >= 0:
			for j in range(32):
				index = i*100+4+j*3
				new_dist = (bin[index+1]*255 + bin[index])
				new_i = (bin[index+2])

				sensor_index = lower_not_upper*32 + j

				theta = new_rot - rot[sensor_index]

				phi = vert[sensor_index]

				r = new_dist + dist[sensor_index]

				x = r*math.cos(theta/180.0*math.pi)*math.cos(phi/180.0*math.pi) + x_off[sensor_index]*math.cos(theta/180.0*math.pi)
				y = r*math.sin(theta/180.0*math.pi)*math.cos(phi/180.0*math.pi) + x_off[sensor_index]*math.sin(theta/180.0*math.pi)
				z = r*math.sin(phi/180.0*math.pi) + z_off[sensor_index]


				#print(str(sensor_index) + ', ' + str(theta) + ', ' + str(phi) + ', ' + str(r) + ', '\
				#	+ str(new_i) + ', ' + str(x) + ', ' + str(y) + ', '+ str(z))
				outfile.write(str(new_i) + ', ' + str(x) + ', ' + str(y) + ', '+ str(z) + '\n')
					
				#output.append(float(new_i))
				#output.append(x)
				#output.append(y)
				#output.append(z)

		# TBD something strange is happening here, the binary file ends
		# up about 6.5 times bigger than it ought to be (16 bytes per position)
		# and the text ends up being smaller
		#output.tofile(outfile)

#if the source file is 98e6 bytes, then there will be 98e6/1206*12*32 = 30.5e6 lines of positions, which will be
# a huge text file
# maybe I should print floats to a binary file instead?

print(len(sys.argv))

f = open(sys.argv[1]) #'unit46monterey.raw')


startind = int(sys.argv[2]) #'unit46monterey.raw')



bin = array.array('B')
bin.fromfile(f, 1206)

#fout = open('output0.bin','wb')
fout = open('output0.csv','wb')

dbfile = open('db.csv','rb')

# calibration data
rotCor = array.array('f')
vertCor = array.array('f')
distCor = array.array('f')
vertOffCor = array.array('f')
horizOffCor = array.array('f')

db = csv.reader(dbfile)
for row in db:
	rotCor.append( float(eval(row[1])) )
	vertCor.append( float(eval(row[2])) )
	distCor.append( float(eval(row[3])) )
	vertOffCor.append( float(eval(row[4])) )
	horizOffCor.append( float(eval(row[5])) )
	#print(rotCor[len(rotCor)-1])

i = 0
j = 0
while (len(bin) == 1206):
	# each call here produces 12*32 new points, i will increment to about 79,000 before this is done
	#if (i%100 == 0): print(i)
	
	# this will have 2604 1206 byte packets per second, so split files int 1 second files
	
	if (j >= startind): 
		processBin1206(bin,fout, rotCor,vertCor,distCor,vertOffCor,horizOffCor)


	bin = array.array('B')
	bin.fromfile(f, 1206)

	i = i+1
	if (i == 2604):
		i = 0
		j = j +1
		#fout = open('output' + str(j) +'.bin','wb')
		if (j >= startind): 
			fout = open('output' + str(j) +'.csv','wb')
