class pt {
  float x;
  float y; 
  
  void update(float t, float offset)
  {
    y += 0.1;
    
    x += 0.8*(noise(x/100.0 + offset, y/100.0 + offset, t) - 0.5);
    y += 0.8*(noise(x/100.0 + offset + 1000, y/100.0 + offset + 1000, t) - 0.5);
  }
 
};

class leaf 
{

  pt pt1;
  pt pt2;
  
  pt ptc1, ptc2, ptc3, ptc4;
  
  float offset;
  float r,g,b;


  leaf(float new_offset, float r, float g, float b) {    
    offset = new_offset;
    this.r = r;
    this.g = g;
    this.b = b;
    
    pt1 = new pt();
    pt2 = new pt();
    ptc1 = new pt();
    ptc2 = new pt();
    ptc3 = new pt();
    ptc4 = new pt();
    
    pt1.x = random(width);
    pt1.y = random(height/10);

    pt2.x = pt1.x + random(width/10);
    pt2.y = pt1.y + random(height/30);
    
    ptc1.x = pt1.x + random(width/15);
    ptc1.y = pt1.y + random(height/45);
    
    ptc2.x = pt1.x + random(width/15);
    ptc2.y = pt1.y + random(height/45);
    
    ptc3.x = pt2.x - random(width/15);
    ptc3.y = pt2.y - random(height/45);
    
    ptc4.x = pt2.x - random(width/15);
    ptc4.y = pt2.y - random(height/45);
  }
  
  void update(float t) 
  {
    pt1.update(t, offset );
    pt2.update(t, offset );
    ptc1.update(t, offset );
    ptc2.update(t, offset );
    ptc3.update(t, offset );
    ptc4.update(t, offset );
  }
  
  void draw()
  {
    stroke(r/3,g/3,b/3);
    fill(r,g,b);
   beginShape();
    vertex(pt2.x, pt2.y);
    bezierVertex(ptc1.x, ptc1.y, ptc2.x, ptc2.y, pt1.x, pt1.y);
    bezierVertex(ptc3.x, ptc3.y, ptc4.x, ptc4.y, pt2.x, pt2.y);
    endShape(); 
  }
}

leaf lf[] = new leaf[200];

void setup() {
  size(640, 480); 
background(20,40,5); 
stroke(34, 10, 0);

//smooth(); 
  
  for (int i = 0; i < lf.length; i++) {
    lf[i] = new leaf(i*0.1, 120 + random(20),20 + random(10), random(5));
  }

}

float t = 0;

void draw() { 
  background(90, 110, 60);
  
   for (int i = 0; i < lf.length; i++) {
    lf[i].update(t);
    lf[i].draw();
   }

t += 0.01;

}
