
float[] pas;
float[] fut;
float[] now;

float x,dx,c;
int nx;
float dt, ctdx2;

float prop = 0.99;

final int nx_sc = 12;
void setup() {
  size(320,nx_sc*20);
  
  frameRate(5);
  
  nx = width/nx_sc;
  pas = new float[nx];
  fut = new float[nx];
  now = new float[nx];

  
  dx = 0.125;
  x = nx*dx;
  
  // wave speed 
  c = 1;
  
  dt = dx/c*prop;
  ctdx2 = (c*dt/dx)*(c*dt/dx);
  
  background(100,100,100);
}

float t = 0;

void draw() {
  PImage tex = get();
  image(tex,-2,-4,width-1, height-1);
  fill(100,100,190,20);
  rect(0,0,width,height);
 
  t += dt;
  /*
   Wave equation
   
   \partial^2 u / \partial t^2 =  c^2  laplacian u
   
   u / dt^2 =  c^2 u/dx^2   
   
   ( (u(T+dt) - u(T))/dt - (u(T) - u(T-dt))/dt )/dt = c^2 ((u(x+1) - u(x))/dx - (u(x) - u(x-1))/dx)/dx
   
   ( u(T+dt) - 2*u(T) + u(T-dt) )/dt^2 = c^2 ( u(x+1) - 2*u(x) + u(x-1) ) /dx^2
   
   u(T+dt) = (dt^2 * c^2 / dx^2) * ( u(x+1) - 2*u(x) + u(x-1) ) + 2 u(t) - u(T-dt)
           
  */
  
  final  float sc = height*0.5;
  
  
  
  for (int i = 1; i < nx-1; i++) {
    fut[i] = ctdx2*(now[i+1] - 2*now[i] + now[i-1]) + 2 * now[i] - pas[i]; 
    
    //print(fut[i] + " " );
   

  }
  //println("");
  
  // right hand boundary condition
  float f = 0.6;
  fut[nx-1] = f*now[nx-2];// ctdx2*(now[nx-1]*0.5 - 2*now[nx-1] + now[nx-2]) + 2 * now[nx-1] - pas[nx-1];
  
  fut[0] = f*now[1]; 
  
  final float maxDt = 2.0;
  if ( t < maxDt ) {
    float env = -0.5*cos(t/maxDt*2*PI) + 0.5;
    fut[0] = env*noise(t/2.0,t/3.0);
  } 

  for (int i = 0; i < fut.length; i++) {
    pas[i] = now[i];
    now[i] = fut[i]; 
    
    if (fut[i] > 0) {
      fill(128.0+255.0*fut[i],0,0,200);
      stroke(155,155,200,200);
    } else {
      fill(105,10,100.0+255.0*fut[i],200);
      stroke(95,55,210,200);
    }
    rect((float)(nx_sc*i), height/2.0, nx_sc,  - fut[i]*sc);
  }
   
}
