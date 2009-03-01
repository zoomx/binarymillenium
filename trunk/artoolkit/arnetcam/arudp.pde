import hypermedia.net.*;


class MarkerInfo {
  float cf;
  int id;
  float area;
  float x;
  float y;
  float rot;
  
  float oldx;
  float oldy;
  float oldrot;
  
  /// ticks since last update
  int count;
  int oldCount;
};



public class arUdp {
  UDP udp;
  
  final int numMarkers = 4;
  boolean have_info = false;
  
  MarkerInfo[] dbInfos = new MarkerInfo[numMarkers];
  
  // temporary space for all raw markerinfos
  public MarkerInfo[] markerInfos = new MarkerInfo[0];
  
  public arUdp() {
      udp = new UDP(this,  5600);
      udp.listen(true);
      
      for (int i = 0; i< dbInfos.length; i++) {

      dbInfos[i] = new MarkerInfo();
    }
  }
  
  void update() {
    
    for (int i = 0; i < dbInfos.length; i++) {
   dbInfos[i].count++;
  }
  
  if (have_info) {
   
    for (int i = 0; i < markerInfos.length; i++) {
     
      if (markerInfos[i].cf > 0.1 ){// && markerInfos[i].id >= 0 ) { 
        
        int newId = markerInfos[i].id;
        if ((newId >= 0) && (newId < numMarkers)) {
          
          
          if (dbInfos[newId].count < 2) {
          dbInfos[newId].oldx = dbInfos[newId].x;
          dbInfos[newId].oldy = dbInfos[newId].y;  
           dbInfos[newId].oldrot = dbInfos[newId].rot;
          } else {
            dbInfos[newId].oldx = markerInfos[i].x;
            dbInfos[newId].oldy = markerInfos[i].y;
            dbInfos[newId].oldrot = markerInfos[i].rot;
          }
          
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
  }
  
  
  public void receive( byte[] data, String ip, int port ) {	// <-- extended handler
  
  MarkerInfo mi = new MarkerInfo();

  mi.id = data[0];
  
  mi.area = arr2float(data, 4);
  mi.cf   = arr2float(data, 8);
  mi.x    = arr2float(data, 12);
  mi.y    = arr2float(data, 16);
  mi.rot  = arr2float(data, 20);

markerInfos = (MarkerInfo[]) append(markerInfos, mi);
have_info = true;

//println(mi.rot + "\n");
 // println(mi.id + ", " + mi.x + ", " + mi.y +
  //      ", receive: \""+ data.length +"\" from "+ip+" on port "+port );

}
};




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



