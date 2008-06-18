sky the_sky;

void setup() {
  the_sky = new sky();
  size(600,600,P3D);
  
  the_sky.draw();
}

boolean toggle = true;
void draw() {
  
  if (mousePressed && toggle) {
    toggle = false;
     the_sky.newSun(mouseX, mouseY); 
     
     print(the_sky.suns.length + "\n");//the_sky.suns[the_sky.suns.length-1].xyz[0] + "\n");
     
      the_sky.draw();
  }
  

  
}

  void mouseReleased() {
     toggle = true; 
  }
