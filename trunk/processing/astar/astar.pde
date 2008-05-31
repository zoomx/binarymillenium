/*
A-star / A* search
binarymillenium June 2008

*/

int MAP_SIZE  = 19;
float MAX_COST = 18.0;
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
  /// where 
 
  float total_cost;  
};

/*
class cost_pos {
  int x;
  int y;
  float cost;
};
*/

class pos {
int x;
int y; 

int old_x;
int old_y;

pos(int x1, int y1, int x2, int y2)
{
    x = x1;
    y = y1;
    old_x = x2;
    old_y = y2;
}

}

pos to_expand[];
int expand_ind = 0;
  
visited visited_map[][];

/// estimate of the cost to get to the goal
float estimated_cost_map[][];
float max_estimate;

float min_cost;
/// the worst cost found so far to anywhere
float worst_cost;

void setup() {
  
  frameRate(10);
  
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
      temp_noise*= temp_noise;
      if (temp_noise > 0.3) temp_noise = 1.0;
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
  
  
  to_expand = new pos[MAP_SIZE*MAP_SIZE*4];
  
  min_cost = 1e6;
  
  
  to_expand[expand_ind++] = new pos(cur_x, cur_y, cur_x-1, cur_y);
  //move();
}

boolean test_pos(int test_x, int test_y, int old_x, int old_y) {
  if ((test_x < MAP_SIZE) &&  (test_y  < MAP_SIZE)  && (test_x >= 0) && (test_y >= 0) && 
        (visited_map[test_x][test_y].expanded != true) && (expand_ind < to_expand.length)  && 
        /*( raw_map[test_x][test_y] < 0.99*MAX_COST) && */
        ((test_x != old_x) || (test_y != old_y))){
    return true;
  } else {
    return false;
  }
}





//cost_pos
void test_cost(/*cost_pos cp, */int test_x, int test_y, int old_x, int old_y) {
  
  /// every move has a cost of 1.0
  float new_cost = visited_map[old_x][old_y].total_cost + 1.0 + raw_map[test_x][test_y];
  
  float test_cost =  new_cost + estimated_cost_map[test_x][test_y];

  print(test_x + " " + test_y + ", " + ei + " " + expand_ind + ", min_cost " + min_cost + ", new_cost " + new_cost + "\n");

  if (test_cost > min_cost) return;   

  /// if this square has been searched before with a lower cost, don't bother updating it with this path    
  if ((visited_map[test_x][test_y].total_cost != 0.0) && (new_cost > visited_map[test_x][test_y].total_cost)) {
    return;
  }
               
  visited_map[test_x][test_y].total_cost = new_cost;
  if (new_cost > worst_cost) worst_cost = new_cost;
           
  visited_map[test_x][test_y].from_x = old_x;
  visited_map[test_x][test_y].from_y = old_y;
       
   /// found the goal? 
   if ((test_x == goal_x) && (test_y == goal_y)) {
      min_cost = new_cost;
      return;
   }
       
       
       
       /////////////////////////////////////////

       
       if (test_pos(test_x+1,test_y,old_x,old_y)) to_expand[expand_ind++] = new pos(test_x+1,test_y, test_x, test_y);
       if (test_pos(test_x,test_y+1,old_x,old_y)) to_expand[expand_ind++] = new pos(test_x,test_y+1, test_x, test_y);
       if (test_pos(test_x,test_y-1,old_x,old_y)) to_expand[expand_ind++] = new pos(test_x,test_y-1, test_x, test_y);
       if (test_pos(test_x-1,test_y,old_x,old_y)) to_expand[expand_ind++] = new pos(test_x-1,test_y, test_x, test_y);

       
       //visited_map[test_x][test_y].expanded = true;
       
}

// expand ind
int ei = 0;
/////////////////////////////////////////////////
void move() {
  
  //int dx = (goal_x - cur_x);
  //int dy = (goal_y - cur_y);
  
  //if ((dx != 0) || (dy != 0)) {
     
   
 
   int next_ind =  min(expand_ind, ei+1, to_expand.length);
   
   while (ei < next_ind) {
     test_cost( to_expand[ei].x,to_expand[ei].y, to_expand[ei].old_x, to_expand[ei].old_y);
     ei++;
     
     //if (ei == expand_ind) print("finished");
    
   }
   
   

  

  //}  
  
  cur_x = to_expand[ei-1].x;
  cur_y = to_expand[ei-1].y;
}



//////////////////////////////////////////
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
       rect(start_x*draw_scale,start_y*draw_scale,draw_scale/2,draw_scale/2);

  color c2 = color(1.0,0,0);
  fill(c2);
       rect(goal_x*draw_scale,goal_y*draw_scale,draw_scale/2,draw_scale/2);

// draw the current position
  color c3 = color(0,0,1.0);
  fill(c3);
       rect(cur_x*draw_scale + draw_scale/4,cur_y*draw_scale + draw_scale/4,draw_scale/2,draw_scale/2);


  move();
}
