
import hypermedia.net.*;

boolean use_saved = true;

 boolean use_texture = false;
 boolean tree_like = true;
boolean use_lateral =false;
boolean all_lateral = false;


UDP udp;

final int COUNT_DIV = 10;
int ind = 1000;
 float range = 5.0;


final int numParticles = 20;

float t = 0.0;
 float div = 30.0;

class MarkerInfo {
  float cf;
  int id;
  float area;
  float x;
  float y;
  float rot;
  
  float oldx;
  float oldy;
  
  /// ticks since last update
  int count;
  int oldCount;
}


/////////////////////////////////////////////////

MarkerInfo[] markerInfos = new MarkerInfo[0];

final int numMarkers = 4;
MarkerInfo[] dbInfos = new MarkerInfo[numMarkers];



boolean have_info = false;


void setup() {
  
  udp = new UDP(this,  5600);
  udp.listen(true);
  
  
  frameRate(5);
  
  //size(1280,720);
  size(400,400);
  
  for (int i = 0; i< dbInfos.length; i++) {
    
 
    
    dbInfos[i] = new MarkerInfo();
  }
  
 



background(255);

}

////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////


int newCounter = 0;

void draw() {
  
  
  //background(0);
  fill(255,150);
  rect(0,0,width,height);
  
  newCounter++;
  if (newCounter > COUNT_DIV) {
    

  newCounter = 0;
  }
  

  //noStroke();
  
  for (int i = 0; i < dbInfos.length; i++) {
   dbInfos[i].count++;
  }
  
  if (have_info) {

    
    for (int i = 0; i < markerInfos.length; i++) {
      
          
       
      if (markerInfos[i].cf > 0.4 ){// && markerInfos[i].id >= 0 ) { 
        
        int newId = markerInfos[i].id;
        if ((newId >= 0) && (newId < numMarkers)) {
          
          /// TBD deep copy?
          dbInfos[newId].oldx = dbInfos[newId].x;
          dbInfos[newId].oldy = dbInfos[newId].y;  
          
          dbInfos[newId].x = markerInfos[i].x; 
          dbInfos[newId].y = markerInfos[i].y;
          
          dbInfos[newId].rot = markerInfos[i].rot; 
       //   dbInfos[newId].y1 = markerInfos[i].y1;
          
          if (dbInfos[newId].count > 0) 
            dbInfos[newId].oldCount = dbInfos[newId].count;
          else 
            dbInfos[newId].oldCount = 1;
            
          dbInfos[newId].count = 0;
        }
        /*
        fill(markerInfos[i].id/3.0*255, markerInfos[i].cf*255,255,128+markerInfos[i].cf*127);      
        rect(width*markerInfos[i].x, height*markerInfos[i].y,10,10);
        */
      }
    }
    markerInfos = new MarkerInfo[0];
    have_info = false;
  }
  
  t+= 0.001;
   
  for (int i = 0; i < dbInfos.length; i++) {
    
      fill(255,0,255*(dbInfos[i].rot+PI)/(2*PI));    
       
       rect(dbInfos[i].x*width, (dbInfos[i].y)*height, 10,10);
        //rect(dbInfos[i].x, (dbInfos[i].y), 10,10);
  }


   
   if (false) {
  for (int i = 1; i < dbInfos.length; i++) {
        fill(255,20);
        if (dbInfos[i].count == 0) {
          fill(255,0,0);
        } else {
           fill(0,255,0); 
        }
        //rect(dbInfos[i].x*width, (dbInfos[i].y)*height, 10,10);
        //rect(dbInfos[i].x, (dbInfos[i].y), 10,10);
       // println(i + "  " + dbInfos[i].x + " " + dbInfos[i].y );
  }
   }

 // saveFrame("frames/splotch#####.png");

}
  
 
 /**
 * To perform any action on datagram reception, you need to implement this 
 * handler in your code. This method will be automatically called by the UDP 
 * object each time he receive a nonnull message.
 * By default, this method have just one argument (the received message as 
 * byte[] array), but in addition, two arguments (representing in order the 
 * sender IP address and his port) can be set like below.
 */
// void receive( byte[] data ) { 			// <-- default handler
void receive( byte[] data, String ip, int port ) {	// <-- extended handler
  
  MarkerInfo mi = new MarkerInfo();
   
  // get the "real" message =
  // forget the ";\n" at the end <-- !!! only for a communication with Pd !!!
 // data = subset(data, 0, data.length-2);
 // String message = new String( data );
  
  // print the result
 
  mi.id = data[0];
  
  mi.area = arr2float(data, 4);
  mi.cf   = arr2float(data, 8);
  mi.x    = arr2float(data, 12);
  mi.y    = arr2float(data, 16);
  mi.rot  = arr2float(data, 20);

markerInfos = (MarkerInfo[]) append(markerInfos, mi);
have_info = true;
 // println(mi.id + ", " + mi.x + ", " + mi.y +
 //       ", receive: \""+ data.length +"\" from "+ip+" on port "+port );

}

float arr2float (byte[] arr, int start) {
		int i = 0;
		int len = 4;
		int cnt = 0;
		byte[] tmp = new byte[len];
		for (i = start; i < (start + len); i++) {
			tmp[cnt] = arr[i];
			cnt++;
		}
		int accum = 0;
		i = 0;
		for ( int shiftBy = 0; shiftBy < 32; shiftBy += 8 ) {
			accum |= ( (long)( tmp[i] & 0xff ) ) << shiftBy;
			i++;
		}
		return Float.intBitsToFloat(accum);
	}


