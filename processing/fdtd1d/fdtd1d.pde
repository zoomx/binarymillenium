
float[] pas;
float[] fut;
float[] now;

float x,dx,c;
int nx;
float dt, ctdx2;

float prop = 0.99;

void setup() {
  size(800,400);
  
  nx = width;
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
  fill(200,100,100,230);
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
  for (int i = 1; i < fut.length-1; i++) {
    fut[i] = ctdx2*(now[i+1] - 2*now[i] + now[i-1]) + 2 * now[i] - pas[i]; 
    
    //print(fut[i] + " " );
    float sc = height*1.0;
    fill(255,0,0,200);
    line((float)i, height/2.0, (float)i, height/2.0 - fut[i]*sc);
  }
  //println("");
  
  for (int i = 0; i < fut.length-1; i++) {
    pas[i] = now[i];
    now[i] = fut[i]; 
  }
  
  if ( t < 2.5 ) {
    fut[0] = noise(t/100.0)-0.5;
  }  else {
    fut[0] = 0;
  }
  
  
}
