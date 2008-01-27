/**
 * Sine. 
 * 
 * Smoothly scaling size with the sin() function. 
 * 
 * Updated 21 August 2002
 */
 
 import krister.Ess.*;
 
float spin = 0.0; 
float diameter = 84.0; 
float angle;

float angle_rot; 
int rad_points = 90;

float dt = 1.0/15.0;


////////////////


AudioChannel myChannel;
FFT myFFT;

AudioStream myStream;
AudioInput myInput;

boolean inputReady=false;
float[] streamBuffer;

/// power of 2
int fft_size = 16;  
  
class target {
 float x,y;
 float vx,vy;
 
 float acc_max = 100;
 
 /// override dynamics and instantaneously change velocity
 void vel(float newvx, float newvy)
 {
   
   
 }
 
void accel(float accx, float accy) 
{
  

    accx = clip(accx, acc_max);
    accy = clip(accy, acc_max);

 
  vx += accx*dt;
  vy += accy*dt;

  x += vx*dt;
  y += vy*dt;
  
  if (x < 0) x = width;
  if (y < 0) y = height;
  if (x > width) x = 0;
  if (y > height) y = 0;
  //x %= width;
 // y %= height;
 
}
}

vehicle chaser;
target tgt;

void setup() 
{

  
  
    // we want 32 frequency bands, so we pass 64
  myFFT = new FFT(fft_size*2);
  
  ////  // start up Ess
  Ess.start(this);

  // create a new AudioInput
  myInput=new AudioInput(); 

  // create a new AudioStream
  myStream=new AudioStream(myInput.size);
  streamBuffer=new float[myInput.size];

  // start
  myStream.start();
  myInput.start();
  
  
    size(400, 400,P3D);
    lights();
  noStroke();
//  smooth();
  
  tgt = new target();
  tgt.x = width/2;
  tgt.y = height/2;
  chaser = new vehicle();
  chaser.acc_max = 1e5; //300.0;
  
  frameRate(1/dt);
}



void audioInputData(AudioInput theInput) {
  System.arraycopy(myInput.buffer,0,streamBuffer,0,myInput.size);
  
  inputReady=true;
}


int i;
void draw() 
{ 

 
 lights();
 
 ////////////////////////
 if (inputReady) {
   //background(30);
    i += 1;
 //if (i == 2) {
   i = 0;
  fill(50,50,50,5);
  rect(0,0,width,height);
 //}
 
  System.arraycopy(streamBuffer,0,myStream.buffer,0,streamBuffer.length);
   
  inputReady=false;
  
  
   // get our spectrum
  myFFT.getSpectrum(myStream);


  // draw our frequency bars
  for (int i=0; i<fft_size; i++) {
    float temp= myFFT.spectrum[i]*fft_size*3e3;
    
    
    fill(250,250,250,10.0*255.0/(float)fft_size);
     stroke(0,0,0,200);
    pushMatrix();
    translate(width/2, height/2);
    beginShape();
    float jmax = 2*i+8;
    
    float amp1 = width/3*(fft_size-i)/fft_size+ width/8;
    float amp2 = (amp1 +temp);
    float amp3 = (amp1 - temp/2.0);
    float phase = (float)i/(float)fft_size*PI;
    
   for (int j = 0; j< jmax; j++) {
    vertex( amp3*cos(2.0*PI*j/jmax + phase),      amp3*sin(2.0*PI*j/jmax + phase) );
    vertex( amp2*cos((2.0*PI*(j+0.5))/jmax +phase), amp2*sin((2.0*PI*(j+0.5))/jmax +phase) );
   }
    endShape();
    popMatrix();

    /*
    float x = (float)i/(float)fft_size*width;
    float x2 = (float)width/(float)fft_size;
    rect(x,0,x2,temp);
    
    pushMatrix();
translate(x, temp,0);
noStroke();
sphere(25);
//stroke();
popMatrix();
*/
  }
  
  
    tgt.x = width/4+ myFFT.spectrum[4]*1e5;
    tgt.y = height/4 +myFFT.spectrum[5]*1e5;
    tgt.accel(0,0);
 // tgt.accel((myFFT.spectrum[100]-myFFT.spectrum[150])*5e5,(myFFT.spectrum[50] - myFFT.spectrum[10])*5e5);
 } 
 
 ///////////////////////
 

 
  float m = 250;
  
  chaser.follow(tgt);
  
  
  //tgt.accel(random(-m,m), random(-m,m));

  fill(255,250,250,220);
  stroke(0,0,0,50);

  //rect(tgt.x-5, tgt.y-5, 10, 10);
  
  
  pushMatrix();
  translate(tgt.x, tgt.y);
    fill(50,250,250,250);
  stroke(100,100,100,30);
  
  rotate(myFFT.spectrum[3]*5e3);
  //rect(myFFT.spectrum[0]*1e6,myFFT.spectrum[6]*1e6, myFFT.spectrum[1]*1e6, myFFT.spectrum[2]*1e6);
  
  popMatrix();
  

}


/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

float clip(float val, float maxval)
{
 if (val > 0) val = min(val, maxval);
 if (val < 0) val = max(val, -maxval);
  
  return val;
}



class vehicle extends target {
  
  float kp = 0.05;
  float kd = 10.0;
  float ki;
  
  float old_ex, old_ey;
  
  void follow(target tgt) 
  {
    float ex = tgt.x - x;
    float ey = tgt.y - y;
    
    float dex = ex-old_ex;
    float dey = ey- old_ey;
    
    accel(ex*kp + dex*kd , ey*kp + dey*kd); 
 
    old_ex = ex;
    old_ey = ey;   
  }
   
}  

