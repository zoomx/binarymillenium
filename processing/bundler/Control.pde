/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
 *
 *  Copyright 2008 Aaron Koblin 
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at 
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
 *  See the License for the specific language governing permissions and
 *  limitations under the License. 
 *
 *//////////////////////////////////////////////////////////////

// Enable the mouse rotation and up and down arrow zooming

/// prerotation offset
float x_off = 0;
float y_off = 0;
float z_off = 0;

/// post rotation offset
float x_off2 = -668;
float y_off2 = -278;
float z_off2 = 1340; //360

float rX = -58;
float rZ = 218;
float vX = 0.0;
float vZ = 0;//0.25;


void rotations(){
  rX+=vX;
  rZ+=vZ;
  vX*=.95;
  vZ*=.95;
  //if (rX >0 ) { vX = -vX*0.5; rX = 0; }
  //if (rX < -95 ) { vX = -vX*0.5; /*rX = -92;*/ }

  if(mousePressed){
    vX+=(mouseY-pmouseY)*.01;
    vZ+=(mouseX-pmouseX)*.01;
    
     //println(rX + " " + rZ + " " + x_off + " " + y_off + " " + z_off);
  }

  rotateX( radians(-rX) );  
  rotateZ( radians(- rZ) );  
  
  rotateX( radians(75) );
  
   translate(x_off2 + width/2, y_off2 + height/2, z_off2); 
}




float pl = 0;
void center(){
  
  
  translate(x_off + width/2, y_off + height/2, z_off);  
  if(false){
  pl += 0.002;
  float inc= (noise(pl)-0.5)*0.005;
  vX += inc;
  
   float inc2= (noise(pl)-0.5)*0.05;
  vZ += inc2;
}
  
  //println(inc);
}

void keyPressed(){
  if(keyCode == UP){
 
  }
  if(keyCode == DOWN){
  
  } 
  
  if(key == 'a'){
    x_off += 10;
  }
  if(key == 'd'){
    x_off -= 8;
  }
  if(key == 'q'){
    y_off += 10;
  }
  if(key == 'z'){
    y_off -= 8;
  }
  if(key == 'w'){
    z_off += 10;
    
    
  }
  if(key == 's'){
    z_off -= 8;
    
    
  }
  
  if (key == 'r') {
    cloud.pointSize *= 1.03;
  }
  
  if (key == 'f') {
    cloud.pointSize *= 0.98;
    
    if (cloud.pointSize < 0.5)
      cloud.pointSize = 0.5;
  }
  if (key == 'v') {
     blendtype = !blendtype; 
  }
  
  print(rX + " " + rZ + ", " + x_off + " " + y_off + " " + z_off + ", " + "\n");
 
 if (false) { 
      if(keyCode == RIGHT){
        counter+= 1;

      //update();
  }
  if(keyCode == LEFT){

  counter -=1;
  if (counter <0 ) counter = 0; 
     // update();
  } 
}
}
