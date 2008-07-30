
import array

def processBin1206(bin):

	dist = array.array('f')
	intensity = array.array('i')

	rot = array.array('f')

	for i in range(12):
		new_rot = (bin[i*100+3]*255 + bin[i*100+2])/100.0
		rot.append(new_rot)
		for j in range(32):
			index = i*100+4+j*3
			new_dist = (bin[index+1]*255 + bin[index])
			dist.append(new_dist)
			new_i = (bin[index+2])
			intensity.append(new_i)

			sensor_index = 0
			if (i%4 > 0): sensor_index = 1
			
			sensor_index = sensor_index*32 + j
			print(str(sensor_index) + ', ' + str(new_rot) + ', ' + str(new_dist) + ', ' + str(new_i))


f = open('unit46monterey_subset.raw')

bin = array.array('B')
bin.fromfile(f, 1206)

while (len(bin) == 1206):
	processBin1206(bin)
	bin = array.array('B')
	bin.fromfile(f, 1206)


