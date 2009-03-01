


boolean use_saved = true;

 boolean use_texture = false;
 boolean tree_like = true;
boolean use_lateral =false;
boolean all_lateral = false;




final int COUNT_DIV = 10;
int ind = 1000;
 float range = 5.0;


final int numParticles = 20;

float t = 0.0;
 float div = 30.0;



/////////////////////////////////////////////////

arUdp theArUdp;


void setup() {
  
  theArUdp = new arUdp();
  
  
  frameRate(5);
  
  //size(1280,720);
  size(400,400);
  
  background(255);

}

////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////


void draw() {
  
  
  //background(0);
  fill(255,150);
  rect(0,0,width,height);
  

  //noStroke();
  
  theArUdp.update();
  
  t+= 0.001;
   
  for (int i = 0; i < theArUdp.dbInfos.length; i++) {
    
      float rot = theArUdp.dbInfos[i].rot;
      float grot = (rot+PI)/(2*PI)*255.0;
      println(grot + "\n");
      
      if (theArUdp.dbInfos[i].count < 2) {
        fill(255,0,grot);    
      } else {
        fill(255,255,grot);    
      }
       
       rect(theArUdp.dbInfos[i].x*width, (theArUdp.dbInfos[i].y)*height, 10,10);
       
       line(theArUdp.dbInfos[i].oldx*width, (theArUdp.dbInfos[i].oldy)*height, 
            theArUdp.dbInfos[i].x*width,    (theArUdp.dbInfos[i].y)*height);
        //rect(dbInfos[i].x, (dbInfos[i].y), 10,10);
  }


   
   if (false) {
  for (int i = 1; i < theArUdp.dbInfos.length; i++) {
        fill(255,20);
        if (theArUdp.dbInfos[i].count == 0) {
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

 void receive( byte[] data, String ip, int port ) {
 theArUdp.receive(data,ip,port); 
  
}


