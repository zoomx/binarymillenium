/*
A-star / A* search
binarymillenium June 2008

*/
int MAP_SIZE  = 15;
float MAX_COST = 10.0;
/// granulariti of cost_map
float DIV = 3.0;
   
float raw_map[][];

int draw_scale = 15;

int start_x;
int start_y;

int goal_x;
int goal_y;

int cur_x;
int cur_y;

class visited {
 
  /// where this node was visited from
  int from_x;
  int from_y;
  
  boolean expanded;
  
  boolean too_costly;
  /// where 
 
  float total_cost;  
};

visited visited_map[][];


class cost_pos {
  int x;
  int y;
  float cost;
};


class pos {
int x;
int y; 

int old_x;
int old_y;

float cost;

boolean flag;

pos(int x1, int y1, int x2, int y2, float new_cost)
{
    x = x1;
    y = y1;
    old_x = x2;
    old_y = y2;
    
    /// estimated cost to goal
    cost = new_cost;
    
    flag = false;
}

}

pos to_expand[];

  
/// estimate of the cost to get to the goal
float estimated_cost_map[][];
float max_estimate;

float min_cost;
/// the worst cost found so far to anywhere
float worst_cost;


///////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
void setup() {
  
  frameRate(30);
  
  visited_map = new visited[MAP_SIZE][MAP_SIZE];
 
  estimated_cost_map = new float[MAP_SIZE][MAP_SIZE];
  
  raw_map = new float[MAP_SIZE][MAP_SIZE];

  start_x = (int)random(0,MAP_SIZE-3)+1;
  start_y = (int)random(0,MAP_SIZE-1)/2+1;
  
  goal_x = (int)random(0,MAP_SIZE-1);
  goal_y =  (int)(0.5+random(0,MAP_SIZE-1)/2);  
  
  for (int i = 0; i < MAP_SIZE; i++) {
  for (int j = 0; j < MAP_SIZE; j++) {
 
      float temp_noise =  (noise(i/DIV,  j/DIV));
      temp_noise*= 1.9/MAX_COST;
      if (temp_noise > 1.0/MAX_COST) temp_noise = 1.0;
      else temp_noise = 0;
     raw_map[i][j] = MAX_COST * temp_noise;
    
     
     
     visited_map[i][j] = new visited();
     visited_map[i][j].expanded = false;
      
     estimated_cost_map[i][j] = abs(i - goal_x) + abs(j - goal_y);
     if (estimated_cost_map[i][j]  > max_estimate) {
        max_estimate = estimated_cost_map[i][j]; 
     }
     
  }
  }
  raw_map[start_x][start_y] = 0.0;
  raw_map[goal_x][goal_y] = 0.0;
  
  cur_x = start_x;
  cur_y = start_y;
  
  size(MAP_SIZE*draw_scale,MAP_SIZE*draw_scale);
  
  colorMode(RGB, 1.0);
  
  min_cost = 1e6;
  
  to_expand = new pos[0]; //MAP_SIZE*MAP_SIZE*4];
  to_expand = (pos[]) append(to_expand, new pos(cur_x, cur_y, cur_x-1, cur_y,estimated_cost_map[cur_x][cur_y] ));
  //move();
}

boolean test_only_pos(int test_x, int test_y) {
  if ((test_x < MAP_SIZE) &&  (test_y  < MAP_SIZE)  && (test_x >= 0) && (test_y >= 0)) 
    return true;
  else 
    return false;
}

boolean test_pos(int test_x, int test_y, int x, int y, int old_x, int old_y, float new_cost) {
   if (test_only_pos(test_x, test_y) && 
        //(visited_map[test_x][test_y].expanded != true)   && 
        //( raw_map[test_x][test_y] < 0.99*MAX_COST) && 
        ((test_x != old_x) || (test_y != old_y)) &&  // don't backtrack
        /// even if this path has been traced, retrace if new_cost is lower
        ((visited_map[test_x][test_y].from_x != x) 
          || (visited_map[test_x][test_y].from_y != y) 
          || ((visited_map[test_x][test_y].total_cost > new_cost)) )
        
        ){
    return true;
  } else {
    return false;
  }
}

////////////////////////////////////////////////////

pos[] append_in_order(pos[] old, pos newpos) {
   pos sorted[] = new pos[old.length + 1];
    
   if ((old.length > 0) && (newpos.cost < old[0].cost)) {
     sorted[0] = newpos;
     arraycopy(old, 0, sorted, 1, old.length);
     return sorted;  
   }
   
   for (int i = 0; i < old.length-1; i++) {
       if ((newpos.cost > old[i].cost) && (newpos.cost <= old[i+1].cost )) {
           /// insert the new pos
           arraycopy(old, sorted, i+1);
           sorted[i+1] = newpos;
           arraycopy(old, i+1, sorted, i+2, old.length - (i+1) );
           
           return sorted;
       }
     
   }

   /// the newpos must have a high cost than all the others in old   
   sorted = (pos[]) append(old, newpos);
   return sorted;
  
}

////////////////////////////////////////////////////////////////////////////////
//cost_pos
void test_cost(int test_x, int test_y, int old_x, int old_y) {
   
    /// every move has a cost of 1.0
  float new_cost = visited_map[old_x][old_y].total_cost + 1.0 + raw_map[test_x][test_y];
  
  /// this position might have been tested since it was put on the  queue
  if (!test_pos(test_x,test_y,old_x,old_y, -1,-1, new_cost)) {
    //visited_map[test_x][test_y].too_costly = true;
      return;
  }
  

  
  float test_cost =  new_cost + estimated_cost_map[test_x][test_y];

  if (test_cost > min_cost) {
    visited_map[test_x][test_y].too_costly = true;
    return;   
  }

  /// if this square has been searched before with a lower cost, don't bother updating it with this path    
  if ((visited_map[test_x][test_y].total_cost != 0.0) && (new_cost > visited_map[test_x][test_y].total_cost)) {
    visited_map[test_x][test_y].too_costly = true;
    return;
  }
               
  visited_map[test_x][test_y].total_cost = new_cost;
  if (new_cost > worst_cost) worst_cost = new_cost;
           
  visited_map[test_x][test_y].from_x = old_x;
  visited_map[test_x][test_y].from_y = old_y;
       
   /// found the goal? 
   if ((test_x == goal_x) && (test_y == goal_y)) {
     
      min_cost = new_cost;
      
      print(" min_cost " + min_cost + ", " + to_expand.length + "\n");
      return;
   }
       

       
       /////////////////////////////////////////
       
       cost_pos next[] = new cost_pos[4];

        for (int i = 0; i < next.length; i++) {
          next[i] = new cost_pos();
        }
        
       next[0].x = test_x+1;  next[0].y = test_y;
       next[1].x = test_x-1;  next[1].y = test_y;
       next[2].x = test_x;    next[2].y = test_y+1;
       next[3].x = test_x;    next[3].y = test_y-1;
              

       for (int i = 0; i < next.length; i++) {
         if (test_pos(next[i].x,next[i].y,test_x, test_y, old_x,old_y, -1.0)) { 
               to_expand = append_in_order(to_expand, 
                              new pos(next[i].x,next[i].y, 
                                      test_x,   test_y, 
                                      estimated_cost_map[next[i].x][next[i].y]));
          }
       }


       
       //visited_map[test_x][test_y].expanded = true;
       
}


//////////////////////////////////

/////////////////////////////////////////////////
void move() {
   
   if (to_expand.length > 0) {
     pos first = to_expand[0];
     pos new_to_expand[] = new pos[to_expand.length-1];
     arraycopy(to_expand, 1, new_to_expand, 0, to_expand.length-1);
     to_expand = new_to_expand;
     
     test_cost( first.x,first.y, first.old_x, first.old_y);
     
        
   cur_x = first.x;
   cur_y = first.y;
   }
   
   
       k++;
  
  if ((k%30 == 0) && (to_expand.length > 0)) {
    print(cur_x + " " + cur_y + ", " + to_expand.length + 
          ", min_cost " + min_cost + ", new_cost " + visited_map[cur_x][cur_y].total_cost + "\n");
  }

}

 int k = 0;
 

////////////////////////////////////////////////////////////////////////////////////////////////

void draw() {
  for (int i = 0; i < MAP_SIZE; i++) {
  for (int j = 0; j < MAP_SIZE; j++) {
    
    /// draw the cost map
    float c = 1.0-(raw_map[i][j]/MAX_COST);
    color c1 = color(c,c,c);
    fill(c1);
    noStroke();
     rect(i*draw_scale,j*draw_scale,draw_scale,draw_scale);
     
     
     if (false) {
     /// draw the estimated cost map
     c = 1.0-estimated_cost_map[i][j]/max_estimate;
    c1 = color(c,c,c/2);
    fill(c1);
    noStroke();
     rect(i*draw_scale+draw_scale/2,j*draw_scale+draw_scale/2,draw_scale/4,draw_scale/4);
     }
     
     /*
     
     if (visited_map[i][j].too_costly) {
         c1 = color(1.0,0.9,0.05);
        fill(c1);
        noStroke();
        rect(i*draw_scale+draw_scale/2,j*draw_scale+draw_scale/2,draw_scale/3,draw_scale/3);
     }
     */
     
  }}
     
     
   for (int i = 0; i < MAP_SIZE; i++) {
   for (int j = 0; j < MAP_SIZE; j++) {
     /// draw the visited cost
     if (visited_map[i][j].total_cost != 0.0) {
       
       /// draw
    float c = 1.0-visited_map[i][j].total_cost/worst_cost;
    color c1 = color(c/2,c,c/2+0.5);
    fill(c1);
    strokeWeight(2);
    stroke(c1);
    //noStroke();
     //rect(i*draw_scale,j*draw_scale+draw_scale/2,draw_scale/4,draw_scale/4);
     
     //strokeWeight(draw_scale/6);
     line( visited_map[i][j].from_x*draw_scale + draw_scale/2,
           visited_map[i][j].from_y*draw_scale + draw_scale/2,
           i*draw_scale + draw_scale/2,
           j*draw_scale + draw_scale/2);
           
     }  
     
  }
  }
  
  
  noStroke();
  
  color c1 = color(0,1.0,0);
  fill(c1);
  rect(start_x*draw_scale+draw_scale/4,start_y*draw_scale+draw_scale/4,draw_scale/2,draw_scale/2);

  color c2 = color(1.0,0,0);
  fill(c2);
  rect(goal_x*draw_scale+draw_scale/4,goal_y*draw_scale+draw_scale/4,draw_scale/2,draw_scale/2);



//////////////////////////////////////////////////
// draw the successful path
if (visited_map[goal_x][goal_y].total_cost != 0.0) {
  
   int x = goal_x;
 int y = goal_y;
 
 strokeWeight(draw_scale/3);
 color c4 = color(0.1,1.0,0.1);
  stroke(c4);
  do {
  
       line( visited_map[x][y].from_x*draw_scale + draw_scale/2+1,
           visited_map[x][y].from_y*draw_scale + draw_scale/2+1,
           x*draw_scale + draw_scale/2+1,
           y*draw_scale + draw_scale/2+1);
           
           x = visited_map[x][y].from_x;
           y = visited_map[x][y].from_y;
           
  } while ((x != start_x) || (y != start_y));
   strokeWeight(2);
}


/// draw positions queued to be evaluated in the future
for (int i = 0; i < to_expand.length; i++) {
  float f = (float)i/to_expand.length;
   color c3 = color(0.3 + f/2.0,f,f);
  fill(c3);
  noStroke();
  
  rect(to_expand[i].x*draw_scale + draw_scale/4,to_expand[i].y*draw_scale + draw_scale/4,
                      draw_scale/3.8,draw_scale/3.5);

}

  // draw the current position
  color c3 = color(0,0,1.0);
  fill(c3);
  rect(cur_x*draw_scale + draw_scale/4,cur_y*draw_scale + draw_scale/4,draw_scale/2,draw_scale/2);


  move();
}
