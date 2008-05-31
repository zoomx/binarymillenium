/*
A-star / A* search
binarymillenium June 2008

*/

int MAP_SIZE  = 40;
float MAX_COST = 18.0;
/// granulariti of cost_map
float DIV = 3.0;
   
float raw_map[][];

int draw_scale = 14;

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
  
  /// where 
 
  float total_cost;  
};

class cost_pos {
  int x;
  int y;
  float cost;
};
  
visited visited_map[][];

/// estimate of the cost to get to the goal
float estimated_cost_map[][];
float max_estimate;

void setup() {
  
  frameRate(2);
  
  visited_map = new visited[MAP_SIZE][MAP_SIZE];
 
  estimated_cost_map = new float[MAP_SIZE][MAP_SIZE];
  
  raw_map = new float[MAP_SIZE][MAP_SIZE];

  start_x = (int)random(0,MAP_SIZE-1);
  start_y = (int)random(0,MAP_SIZE-1)/2;
  
  goal_x = (int)random(0,MAP_SIZE-1);
  goal_y =  (int)(0.5+random(0,MAP_SIZE-1)/2);  
  
  for (int i = 0; i < MAP_SIZE; i++) {
  for (int j = 0; j < MAP_SIZE; j++) {
 
     raw_map[i][j] = MAX_COST * (noise(i/DIV,  j/DIV));
     
     visited_map[i][j] = new visited();
      
     estimated_cost_map[i][j] = abs(i - goal_x) + abs(j - goal_y);
     if (estimated_cost_map[i][j]  > max_estimate) {
        max_estimate = estimated_cost_map[i][j]; 
     }
     
  }
  }
  
  cur_x = start_x;
  cur_y = start_y;
  
  size(MAP_SIZE*draw_scale,MAP_SIZE*draw_scale);
  
  colorMode(RGB, 1.0);
}



cost_pos test_cost(cost_pos cp, int test_x, int test_y) {
  
  if ((test_x < MAP_SIZE-1) &&  (test_y  < MAP_SIZE-1)  && (test_x >= 0) && (test_y >= 0)) {
     
       float new_cost =  raw_map[test_x][test_y] + estimated_cost_map[test_x][test_y];

       if ((new_cost < cp.cost) && (visited_map[test_x][test_y].total_cost == 0.0)) {
           cp.cost = new_cost ;  
         
           cp.x = test_x;
           cp.y = test_y; 
       }
       
       if ((test_x == goal_x) && (test_y == goal_y)) {
           cp.cost = 0;  
         
           cp.x = test_x;
           cp.y = test_y; 
       }
     } 
   
   return cp;
}

/////////////////////////////////////////////////
void move() {
  
  int dx = (goal_x - cur_x);
  int dy = (goal_y - cur_y);
  
  if ((dx != 0) || (dy != 0)) {
    
   cost_pos cp = new cost_pos();
   cp.x = cur_x;
   cp.y = cur_y;
   cp.cost = 1e6;
   
  cp = test_cost(cp, cur_x-1,cur_y);
  cp = test_cost(cp, cur_x+1,cur_y);
  cp = test_cost(cp, cur_x,cur_y+1);
  cp = test_cost(cp, cur_x,cur_y-1);
  
    //////////////////////////////////////////////////////
    
    int new_x = cp.x;
    int new_y = cp.y;

  
  /// every move has a cost of 1.0
    visited_map[new_x][new_y].total_cost = visited_map[cur_x][cur_y].total_cost + 1.0 + raw_map[new_x][new_y];
  
    cur_x = new_x;
    cur_y = new_y;
  
    print(visited_map[cur_x][cur_y].total_cost + ", original estimate: " + 
                                                 estimated_cost_map[start_x][start_y] + "\n");
       
  }  
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
     
     /// draw the visited cost
     
     /// draw the estimated cost map
     if (visited_map[i][j].total_cost != 0.0) {
     c = 1.0-visited_map[i][j].total_cost/visited_map[cur_x][cur_y].total_cost;
    c1 = color(c/2,c,c/2);
    fill(c1);
    noStroke();
     rect(i*draw_scale,j*draw_scale+draw_scale/2,draw_scale/4,draw_scale/4);
     }
  }
  }
  
  
  color c1 = color(0,1.0,0);
  fill(c1);
       rect(start_x*draw_scale,start_y*draw_scale,draw_scale/2,draw_scale/2);

  color c2 = color(1.0,0,0);
  fill(c2);
       rect(goal_x*draw_scale,goal_y*draw_scale,draw_scale/2,draw_scale/2);

  color c3 = color(0,0,1.0);
  fill(c3);
       rect(cur_x*draw_scale + draw_scale/2,cur_y*draw_scale,draw_scale/2,draw_scale/2);


  move();
}
