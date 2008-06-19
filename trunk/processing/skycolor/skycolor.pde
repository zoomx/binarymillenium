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
       
    if (mouseButton == LEFT) {
       the_sky.newSun(mouseX, height-mouseY);  
    } else if (mouseButton == RIGHT) {     
       the_sky.replaceSun(mouseX,height- mouseY); 
    }
     print(the_sky.suns.length + "\n");//the_sky.suns[the_sky.suns.length-1].xyz[0] + "\n");
    
    the_sky.draw();
  }
  
  if (keyPressed && toggle) {
    toggle = false;
     
     if (key == 't') {
        the_sky.turbidity *= 1.05;
        print(the_sky.turbidity + "\n");
     }   
     
     if (key == 'r') {
        the_sky.turbidity /= 1.02;
        
        print(the_sky.turbidity + "\n");
     }  
     
     if (key == 'g') {
       the_sky.g *=1.03;
         print(the_sky.g + "\n");
     }
     if (key == 'b') {
       the_sky.g /=1.02;
         print(the_sky.g + "\n");
     }
     
     if (key == 'd') {
       the_sky.gain *=1.05;
         print(the_sky.gain + "\n");
     }
     if (key == 'e') {
       the_sky.gain /= 1.02; 
       
       print(the_sky.gain + "\n");
     }
    
     the_sky.compute(); 
     the_sky.draw();
  }
  

  
}

  void mouseReleased() {
     toggle = true; 
  }
  
  void keyReleased() {
     toggle = true; 
  }
