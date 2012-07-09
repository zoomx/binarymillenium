import processing.opengl.*;


import procontroll.*;
import net.java.games.input.*;

ControllIO controllIO;
ControllDevice joypad;
ControllStick stick1;
ControllStick stick2;


float transX;
float transY;

color col1, col2;

float old_x1, old_y1, old_x2, old_y2;

boolean use_joy = false;

void setup(){
  size(1000,600);

  transX = width/2;
  transY = height/2;

  controllIO = ControllIO.getInstance(this);

  if (controllIO.getNumberOfDevices() <= 0) {
    return; 
  }
 
  use_joy = true;
  joypad = controllIO.getDevice(0);
  //joypad.plug(this, "handleButton1Press", ControllIO.ON_PRESS, 0);
  //joypad.plug(this, "handleButton1Release", ControllIO.ON_RELEASE, 1);
  //joypad.plug(this, "handleMovement", ControllIO.ON_PRESS, 0);//ControllIO.WHILE_PRESS, 1);

  stick1 = joypad.getStick(1);
  stick1.setTolerance(0.0f);
  stick1.setMultiplier(1.0f);
  //stick1.setMultiplier(PI);

  stick2 = joypad.getStick(0);
  stick2.setTolerance(0.0f);
  stick2.setMultiplier(1.0f);
  
  joypad.printSticks();
  
  col1 = color(255,128,128);
  col2 = color(0,0,255);
  
  background(0);
  
  old_x1 = width/2;
  old_x2 = width/2;
  old_y1 = height/2;
  old_y2 = height/2;
}

void handleButton1Press(){
  fill(255,0,0);
  joypad.rumble(1);
}

void handleButton1Release(){
  fill(255);
}

void handleMovement() //final float i_x,final float i_y)
{
// println("test");
 // transY += i_y;
}

void draw(){
  
  fill(0,2);
  rect(0,0,width,height);
  
  if (!use_joy) return;
  //background(0,240);
  
  int wd = 8;
  float fr = 0.95;
  strokeWeight(wd);
  
  {
  float x1 = width/2  + fr*stick1.getY()*(width/2-wd/2);
  float y1 = height/2 + fr*stick1.getX()*(height/2-wd/2);
  
  strokeWeight(wd+2);
  stroke(0);
  line(old_x1, old_y1,x1,y1);
  strokeWeight(wd);
  stroke(col1);
  line(old_x1, old_y1,x1,y1);
  
  old_x1 = x1;
  old_y1 = y1;
  }
  
  {
    float r1 = red(col1);
    r1 = 128 + stick2.getY() * 128;
    if (r1 > 255) { r1 = 255; }
    //r1 %= 255;
    
    float g1 = green(col1);
    g1 = 128 + stick2.getX() * 128;
    //g1 %= 255;
    
    col1 = color(r1, g1, blue(col1));
  }
  if (true) {

  float x2 = width/2  + fr*stick2.getY()*(width/2-wd/2);
  float y2 = height/2 + fr*stick2.getX()*(height/2-wd/2);
  
  strokeWeight(wd+2);
  stroke(0);
  line(old_x2, old_y2,x2,y2);
  strokeWeight(wd);
  stroke(col2);
  line(old_x2, old_y2,x2,y2);
  
  old_x2 = x2;
  old_y2 = y2;
  }
}
