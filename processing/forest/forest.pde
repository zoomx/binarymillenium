/*
This code is licensed under the GPL 3.0

Binarymillenium September 2011
*/

class pt {
  float x;
  float y; 
  
  pt()
  {
    
  }
  
  pt(float x, float y)
  {
    this.x = x;
    this.y = y;  
  }
  
  void update(float t, float offset)
  {
    y += 0.1;
    
    x += 0.8*(noise(x/100.0 + offset, y/100.0 + offset, t) - 0.5);
    y += 0.8*(noise(x/100.0 + offset + 1000, y/100.0 + offset + 1000, t) - 0.5);
  }
 
};

//////////////////////////////////////////////////////////////////////////////////
class leaf 
{

  pt pt1;
  pt pt2;
  
  pt ptc1, ptc2, ptc3, ptc4;
  
  float offset;
  float r,g,b;


  leaf(float new_offset, pt pt1, pt pt2, float r, float g, float b) 
  {    
    offset = new_offset;
    this.r = r;
    this.g = g;
    this.b = b;
    
    this.pt1 = pt1;
    this.pt2 = pt2;
    ptc1 = new pt();
    ptc2 = new pt();
    ptc3 = new pt();
    ptc4 = new pt();
    
    float wd = abs(pt1.x - pt2.x);
    float ht = abs(pt1.y - pt2.y);
    
    float ln = sqrt(wd*wd + ht*ht);
    
  
    ptc1.x = pt1.x + random(wd + ln/2);
    ptc1.y = pt1.y + random(ht + ln/2);
    
    ptc2.x = pt1.x + random(wd+ ln/2);
    ptc2.y = pt1.y + random(ht+ ln/2);
    
    ptc3.x = pt2.x - random(wd + ln/2);
    ptc3.y = pt2.y - random(ht);
    
    ptc4.x = pt2.x - random(wd+ ln/2);
    ptc4.y = pt2.y - random(ht+ ln/2);
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

/////////////////////////////////////////////////////////////////////////////
class tree {
  
  pt base;
  float r,g,b;
  float wd;
  float ht;
  
  leaf grass[] = new leaf[35];
  leaf lf[] = new leaf[80];
  
  tree(pt base, float wd, float ht) 
  {
     this.base = base; 
        
     r = 255*(random(0.2) + 0.7);
     g = 255*(random(0.2) + 0.4);
     b = 255*random(0.2);
     
     this.wd = wd;
     this.ht = ht;

     for (int i = 0; i < grass.length; i++) {
       pt pt1 = new pt(base.x + random(-70, 70), base.y + 10 + random(5));
       pt pt2 = new pt(pt1.x  + random(-5, 5),   base.y -  5 - random(5));
       grass[i] = new leaf( random(2000), pt1, pt2, 25 + random(5), 160 + random(10), 1 ); 
     }
     
     
     for (int i = 0; i < lf.length; i++) {
    
    pt pt1 = new pt();
    float rng = 70;
    pt1.x = base.x + random(-rng, rng);
    pt1.y = base.y - ht - 70 + random(-rng/2, rng/2);

    pt pt2 = new pt();
    float rng2 = 25;
    pt2.x = pt1.x + random(-rng2,rng2);
    pt2.y = pt1.y + random(-rng2,rng2);
    lf[i] = new leaf(i*0.1, pt1, pt2, 120 + random(20), 20 + random(10), random(5));
  }
   }
  
  void drawBranch(pt tg)
  {
    beginShape();
    curveVertex(base.x - wd/2, base.y - ht + 1 + random(10));
    curveVertex(base.x - wd/2, base.y - ht + 1);
    
    for (int i = 1; i < 5; i++) {
      float x = base.x - wd/2 - random(5-i) + tg.x*i/5.0;
      float y = base.y - ht  - random(5) - tg.y*i/5.0;
      curveVertex(x, y);
    }    
    curveVertex(base.x + tg.x + random(5), base.y - ht - tg.y - random(5));
    curveVertex(base.x + tg.x + random(5), base.y - ht - tg.y - random(5));
     
    for (int i = 5; i > 0; i--) {
       float x = base.x + wd/2 + random(5-i) + tg.x*i/5.0;
      float y = base.y - ht  - random(5) - tg.y*i/5.0;
      curveVertex(x, y);
    }
    
    curveVertex(base.x + wd/2, base.y - ht + 1);
    curveVertex(base.x + wd/2, base.y - ht + 1 + random(10));
    endShape();
  }
  
  void update()
  {
    base.x += random(-1,1);  
    
    for (int i = 0; i < grass.length; i++) { 
       grass[i].pt2.x += random(-1,1); 
    }
    
     for (int i = 0; i < lf.length; i++) {
      lf[i].update(t);
      lf[i].pt1.x += random(-1,1);
      lf[i].pt1.y += random(-1,1);
      lf[i].pt2.x += random(-1,1);
      lf[i].pt2.y += random(-1,1);
     }
  }
  
  void draw()
  {
    stroke(r/3, g/3, b/3);
    fill(r, g, b);
    
    beginShape();
    vertex(base.x - wd/2, base.y);
    vertex(base.x - wd/2, base.y - ht);
    vertex(base.x + wd/2, base.y - ht);
    vertex(base.x + wd/2, base.y);    
    endShape(); 
    
    int num_branch = 5;
    for (int i = -num_branch/2; i < num_branch/2; i++) {
      drawBranch(new pt(i*40,  80 + random(10)));
 
    }
    
    for (int i = 0; i < grass.length; i++) {    
      grass[i].draw();
    }
    
    for (int i = 0; i < lf.length; i++) {
      lf[i].draw();
   }
  }
}

tree trees[] = new tree[65];



void setup() {
  //size(640, 480); 
  size(1280, 720); 
  background(20,40,5); 
  stroke(34, 10, 0);
  strokeWeight(2);
  frameRate(10);

  //smooth(); 
  

  
  for (int i = 0; i < trees.length; i++) {
    trees[i] = new tree(new pt(random(width), height*0.8 + (float)i/trees.length*50),
                        width/90 + random(width/90) + i/3, random(height/4 + 2*i) + height/5 + i
                          );
  }

}

float t = 0;

void draw() { 
  background(140, 150, 130);
  fill(155,125,0);
  rect(0, height*0.8 +random(1), width, height);
  
  for (int i = 0; i < trees.length; i++) {
    trees[i].update();
    trees[i].draw();
    
    if (i % (int)(trees.length/10+1) == 0) {
       fill(90, 110, 60, 13);
       rect(0, 0, width, height);
    }
  }
  
  saveFrame();

t += 0.01;

}
