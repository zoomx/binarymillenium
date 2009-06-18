
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
  
  part(PImage tex, float x, float y, float z) {
      img = tex;
      
      this.x = x;
      this.y = y;
      this.z = z;
  }

  void draw() {
    
    vx += noise(x,y,z)/100.0;
    vy += noise(100 + x, 100 + y, 100+z)/100.0;
    vz += noise(200 + x, 200 + y, 200+z)/100.0;
    
    x += vx;
    y += vy;
    z += vz;
    
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

part[] parts = new part[1000];

void setup() {
  size(640,480,P3D);
  ble = loadImage("images/blue.png");
  crc = loadImage("images/circ.png");
 
  noStroke(); 
  
  for (int i = 0; i < parts.length; i++) {
    parts[i] = new part(ble, random(-500,500), random(-500,500) ,random(-500,500)); 
  }
  
  background(0);
  
}


float x_pos = 100;
float y_pos = 100;

float ind = random(10);
float ind2 = random(10);

void draw() {
  
  fill(0,0,0,1);
  rect(0,0,width, height);
  
  ind += 0.1;
  
  //background(0);
  translate(width/2, height/2);
  
  x_pos += noise(x_pos+ind, y_pos +ind);
  y_pos += noise(x_pos+ind2, y_pos+ind2);

  for (int i = 0; i < parts.length; i++) {
    parts[i].draw(); 
  }
  
}

