import math
import array
import csv

def processBin1206(bin,rot,vert,dist,z_off,x_off):

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

				#if sensor_index <32: z = -z

				print(str(sensor_index) + ', ' + str(theta) + ', ' + str(phi) + ', ' + str(r) + ', '\
					+ str(new_i) + ', ' + str(x) + ', ' + str(y) + ', '+ str(z))


f = open('unit46monterey_subset.raw')

bin = array.array('B')
bin.fromfile(f, 1206)

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


#while (len(bin) == 1206):
for i in range(1000):	
	processBin1206(bin,rotCor,vertCor,distCor,vertOffCor,horizOffCor)
	bin = array.array('B')
	bin.fromfile(f, 1206)


