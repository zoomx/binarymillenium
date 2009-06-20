
PImage ble;
PImage crc;

class part {
  
  PImage img;
  
  float x;
  float y;
  float z;
  
  float vx;
  float vy;
  float vz;
  
  float angle = 0;
  
  float noiseScale = 1/100.0;
  
  part(PImage tex, float x, float y, float z) {
      img = tex;
      
      this.x = x;
      this.y = y;
      this.z = z;
  }

  void update() 
  {
     
    vx += noise(x,y,z)*noiseScale;
    vy += noise(100 + x, 100 + y, 100+z)*noiseScale;
    vz += noise(200 + x, 200 + y, 200+z)*noiseScale;
    
    x += vx;
    y += vy;
    z += vz;
  }

  void draw() {
 
    update();
    
    pushMatrix();
    
    translate(x,y,z);
    
    
    beginShape(QUADS);
    texture(img);
    vertex(-10, -10, 0, 0,   0);
    vertex( 10, -10, 0, 100, 0);
    vertex( 10,  10, 0, 100, 100);
    vertex(-10,  10, 0, 0,   100);
    endShape(); 
  
    popMatrix();  
  }
};

class world extends part
{
  
  world(PImage tex, float x, float y, float z) {
    super(tex,x,y,z);
    
    noiseScale = 1/10000.0;
  }
  
  void draw() {
   // update(); 
    angle+=PI/250.0;
    
    pushMatrix();
    
    fill(255,200,120);
    stroke(100,255,50);
    translate(x,y,z);
    
    rotateY(angle);
    
    float r = 100.0;
    int maxInd = 12;
    
    for (int i = 0; i < maxInd; i++) {
      beginShape(QUAD_STRIP);
       texture(img);
       float psi = (float)i/(float)maxInd*PI-PI/2;
       float psi2= (float)(i+1)/(float)maxInd*PI-PI/2;
      
       for (int j = 0; j <= maxInd; j++) {  
         float theta = (float)j/(float)maxInd*2*PI;
        
          vertex( r*cos(theta)*cos(psi),  r*sin(theta)*cos(psi),  r*sin(psi));// (float)j/(float)maxInd*100.0,     (float)i/(float)maxInd*100.0);
          vertex( r*cos(theta)*cos(psi2), r*sin(theta)*cos(psi2), r*sin(psi2));// (float)(j)/(float)maxInd*100.0, (float)(i+1)/(float)maxInd*100.0);
        }
      
       endShape(); 
    }
    // vertex( 10,  10, 0, 100, 100);
    // vertex(-10,  10, 0, 0,   100);

  
    popMatrix(); 

  }
};

part[] parts = new part[1000];
world[] worlds = new world[1];

void setup() {
  size(640,480,P3D);
  ble = loadImage("images/blue.png");
  crc = loadImage("images/circ.png");
 
  noStroke(); 
  
  for (int i = 0; i < parts.length; i++) {
    parts[i] = new part(ble, random(-500,500), random(-500,500) ,random(-500,500)); 
  }
  
  for (int i = 0; i< worlds.length; i++) {
    worlds[i] = new world(ble, 0,0,0); //random(-200,200), random(-200,200) ,random(-200,200)); 
  }
  
  background(0);
  
}


float x_pos = 100;
float y_pos = 100;

float ind = random(10);
float ind2 = random(10);

void draw() {
  
  //fill(0,0,0,1);
  //rect(0,0,width, height);
  
  ind += 0.1;
  lights();
  
  background(0);
  translate(width/2, height/2);
  
  x_pos += noise(x_pos+ind, y_pos +ind);
  y_pos += noise(x_pos+ind2, y_pos+ind2);

 for (int i = 0; i < worlds.length; i++) {
    worlds[i].draw(); 
  }
  for (int i = 0; i < parts.length; i++) {
   // parts[i].draw(); 
  }
  
}

