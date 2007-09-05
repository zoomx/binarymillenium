/*
 * binarymillenium 2007
 * GNU GPL
 */

// Video out voltage levels
#define _SYNC 0x00
#define _BLACK  0x01
#define _GRAY  0x02
#define _WHITE  0x03

// dimensions of the screen
#define WIDTH 25
#define HEIGHT 32

byte fb[WIDTH][HEIGHT+1];

//#define LINE_PERIOD 63.625
#define LINE_PERIOD 63.3
// 63.45 stable but wrong

//#define PIX_DELAY 1
//#define LINE_DELAY 45
/// curved to right means the h line is too long
#define LINE_DELAY 43
//25

// supposed to be 5?
#define SYNC_PERIOD 4.7
#define FRONTPORCH_PERIOD 1.4
#define BACKPORCH_PERIOD 5.9

//number of lines to display
#define DISPLAY_LINES 242
//236 -doesn't scroll, but jitters
//242
#define VSYNC_LINES 20
/// total 262 lines  


//video pins
#define DATA_PIN 9
#define SYNC_PIN 8


int index, index2;

void clearScreen()
{
    for (index = 0; index < WIDTH; index++)
      for (index2=0;index2<HEIGHT;index2++)
        {
         fb[index][index2] = _BLACK;
         
        }
        
}

 short counter = 0;

void updateScreen()
{
      for (index = 0; index < WIDTH; index++) {
      for (index2=0;index2<HEIGHT-1;index2++)
        {
        /*  if (index2 & 0x01)
         fb[index][index2] = ((counter>>4)+index)%3+1; //(((counter+index2)/10)%3)+1;
         else
         fb[index][index2] = ((counter>>4)+index+1)%3+1; //(((counter+index2)/10)%3)+1;
         */
         fb[index][index2] = fb[index][index2+((counter & 0xf) == 0xf)];
        }
        
        if ((counter>>2 & 0x01))
        fb[index][index2] = fb[index][0];
        else
        fb[index][index2] = fb[index][0];
      }
  
}

void randomScreen()
{
      for (index = 0; index < WIDTH; index++)
      for (index2=0;index2<HEIGHT;index2++)
        {
         //fb[index][index2] =(rand()%3 +1) + (rand()%3 +1)<<2 + (rand()%3 +1) <<4 + (rand()%3 +1)<<6;
         fb[index][index2] =(rand()%256);
         
          if ((fb[index][index2] & 0x3) == 0) fb[index][index2] = _BLACK;
      if (((fb[index][index2] >> 2) & 0x03) == 0) fb[index][index2] = _BLACK;
      if (((fb[index][index2] >> 4) & 0x03) == 0) fb[index][index2] = _BLACK;
      if (((fb[index][index2] >> 6) & 0x03) == 0) fb[index][index2] = _BLACK;
         
        }
  
}

void bmScreen()
{

  int x,y; 
  x = 1;
  y = 1;
  
  /// b
  
  fb[x][y] = _WHITE;
  fb[x][y+1] = _WHITE;
  fb[x][y+2] = _WHITE;
  fb[x][y+3] = _WHITE;
  
  fb[x+1][y+1] = _WHITE;
  fb[x+2][y+2] = _WHITE;
  fb[x+1][y+3] = _WHITE;
  
  x +=4;
  // i
  fb[x][y] = _WHITE;
  fb[x][y+2] = _WHITE;
  fb[x][y+3] = _WHITE;
  
  x+=2;
  
  // n
  fb[x+1][y+1] = _WHITE;
  fb[x][y+2] = _WHITE;
  fb[x][y+3] = _WHITE;
  x+=2;
   
  fb[x][y+2] = _WHITE;
  fb[x][y+3] = _WHITE;
  
  x+=2;
  // a
  fb[x][y+2] = _WHITE;
  
  fb[x+1][y+1] = _WHITE;
  fb[x+2][y+2] = _WHITE;
  fb[x+1][y+3] = _WHITE;
  
   fb[x+2][y+3] = _WHITE;
  
  x+=4;
  // r
  fb[x+1][y+1] = _WHITE;
  fb[x][y+2] = _WHITE;
  fb[x][y+3] = _WHITE;
  
  x+=3;
  // y
  fb[x][y+2] = _WHITE;
  fb[x+1][y+3] = _WHITE;
  
  
  fb[x+2][y+2] = _WHITE;
  fb[x+2][y+3] = _WHITE;
  fb[x+2][y+4] = _WHITE;
  
  x+=4;
  // m

  fb[x][y+2] = _WHITE;
  fb[x][y+3] = _WHITE;
  
  fb[x+1][y+1] = _WHITE;
  
  x+=2;
  fb[x][y+2] = _WHITE;
  fb[x][y+3] = _WHITE;
  fb[x+1][y+1] = _WHITE;
  
  x+=2;
    fb[x][y+2] = _WHITE;
  fb[x][y+3] = _WHITE;
  
  
}

void setup()                    // run once, when the sketch starts
{
  /// disable the interrupt, this produces a much more steady image 
  /// even if the timing is still wrong
  cli();
  clearScreen();
  int i;
  /*for (i = 0; i < 10; i++) {
    fb[10][i] = _WHITE;
    fb[i+5][10] = _GRAY;
  }*/
  
 randomScreen();
 //clearScreen();
  bmScreen();
  /*
    for (index = 0; index < WIDTH; index++)
      for (index2=0;index2<HEIGHT;++index2)
        {
         fb[index][index2] = _WHITE;
        }
        */
  
  
  pinMode (SYNC_PIN, OUTPUT);
  pinMode (DATA_PIN, OUTPUT);
  digitalWrite (SYNC_PIN, HIGH);
  digitalWrite (DATA_PIN, HIGH);
  
}


 
void loop()                     // run over and over again
{
  int line, newLine;
  counter++;
  
  for ( line =0;line< DISPLAY_LINES;++line)
    {
      // 'front porch' - to make sure there's a transition?
      //PORTB = _BLACK;
      //delayMicroseconds(1.5);
      // sync - should be 5 us for NTSC Rs170
      PORTB = _SYNC;
      delayMicroseconds(SYNC_PERIOD);
      PORTB = _BLACK;
      // no image for 5 us
      delayMicroseconds(BACKPORCH_PERIOD);
     
     newLine = line >>3;
     
     if (line%2 ==0) {
        PORTB = _WHITE;
       delayMicroseconds(3);
       PORTB = _BLACK;
       delayMicroseconds(3);
       PORTB = _GRAY;
       delayMicroseconds(3);
     } else {
       
               PORTB = _BLACK;
       delayMicroseconds(3);
       PORTB = _BLACK;
       delayMicroseconds(3);
       PORTB = _GRAY;
       delayMicroseconds(3);
     }
       
     
     int i = 0;
   // for (i = 0; i < 40; i++) {
    // PORTB = fb[i][newLine];
    //} 
    
   
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
      /// 16
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
      // 32
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
      // 48
      
      
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
      /// 64
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
      // 80
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03; 
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
      // 96
  
  #if 0
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;

      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
      /// 16
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;

      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
      // 32
            PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;

      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
      PORTB = (fb[i][newLine]) & 0x3;
      PORTB = (fb[i][newLine] >> 2) & 0x03;
      PORTB = (fb[i][newLine] >> 4) & 0x03;
      PORTB = (fb[i][newLine] >> 6) & 0x03;   
      i++;
      
      // 48
  #endif
  
   #if 0
      PORTB = fb[1][newLine];
      //delayMicroseconds(PIX_DELAY);
      
      PORTB = fb[2][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[3][newLine];
      //delayMicroseconds(PIX_DELAY);
      
      PORTB = fb[4][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[5][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[6][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[7][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[8][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[9][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[10][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[11][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[12][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[13][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[14][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[15][newLine];
      //delayMicroseconds(PIX_DELAY);
      
      PORTB = fb[16][newLine];
      //delayMicroseconds(PIX_DELAY);
      
      PORTB = fb[17][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[18][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[19][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[20][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[21][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[22][newLine];
      //delayMicroseconds(PIX_DELAY);     
      PORTB = fb[23][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[24][newLine];
      //delayMicroseconds(PIX_DELAY);     
      PORTB = fb[25][newLine];
      //delayMicroseconds(PIX_DELAY);
      
      PORTB = fb[26][newLine];
      PORTB = fb[27][newLine];
      PORTB = fb[28][newLine];
      PORTB = fb[29][newLine];
      PORTB = fb[30][newLine];
      PORTB = fb[31][newLine];
      PORTB = fb[32][newLine];
      PORTB = fb[33][newLine];
      PORTB = fb[34][newLine];
      PORTB = fb[35][newLine];
      PORTB = fb[36][newLine];
      PORTB = fb[37][newLine];
      PORTB = fb[38][newLine];
      PORTB = fb[39][newLine];
      PORTB = fb[40][newLine];
      PORTB = fb[41][newLine];
      PORTB = fb[42][newLine];
      PORTB = fb[43][newLine];
      PORTB = fb[44][newLine];
      PORTB = fb[45][newLine];
      PORTB = fb[46][newLine];
      
      PORTB = (fb[47][newLine]) & 0x3;
      PORTB = (fb[47][newLine] >> 2) & 0x03;
      PORTB = (fb[47][newLine] >> 4) & 0x03;
      PORTB = (fb[47][newLine] >> 6) & 0x03;      
  
      PORTB = fb[48][newLine];
      
//////////////////////////////////////
      PORTB = fb[0][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[1][newLine];
      //delayMicroseconds(PIX_DELAY);
      
      PORTB = fb[2][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[3][newLine];
      //delayMicroseconds(PIX_DELAY);
      
      PORTB = fb[4][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[5][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[6][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[7][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[8][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[9][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[10][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[11][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[12][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[13][newLine];
      //delayMicroseconds(PIX_DELAY);
      PORTB = fb[14][newLine];
      //delayMicroseconds(PIX_DELAY);
      #endif
      
      /*
      PORTB = fb[15][newLine];
      PORTB = fb[16][newLine];
      PORTB = fb[17][newLine];
      PORTB = fb[18][newLine];
      PORTB = fb[19][newLine];
      PORTB = fb[20][newLine];
      PORTB = fb[21][newLine];
      PORTB = fb[22][newLine];  
      PORTB = fb[23][newLine];
      PORTB = fb[24][newLine]; 
      
      PORTB = fb[25][newLine];
      PORTB = fb[26][newLine];
      PORTB = fb[27][newLine];
      PORTB = fb[28][newLine];
      PORTB = fb[29][newLine];
      PORTB = fb[30][newLine];
      PORTB = fb[31][newLine];
      PORTB = fb[32][newLine];
      PORTB = fb[33][newLine];
      PORTB = fb[34][newLine];
      PORTB = fb[35][newLine];
      PORTB = fb[36][newLine];
      PORTB = fb[37][newLine];
      PORTB = fb[38][newLine];
      PORTB = fb[39][newLine];
      PORTB = fb[40][newLine];
      PORTB = fb[41][newLine];
      PORTB = fb[42][newLine];
      PORTB = fb[43][newLine];
      PORTB = fb[44][newLine];
      PORTB = fb[45][newLine];
      PORTB = fb[46][newLine];
      
      PORTB = (fb[47][newLine]) & 0x3;
      PORTB = (fb[47][newLine] >> 2) & 0x03;
      PORTB = (fb[47][newLine] >> 4) & 0x03;
      PORTB = (fb[47][newLine] >> 6) & 0x03;      
  
      PORTB = fb[48][newLine];
      */
      ////
      
     
      PORTB = _BLACK;
      delayMicroseconds(LINE_PERIOD - SYNC_PERIOD - BACKPORCH_PERIOD - FRONTPORCH_PERIOD- LINE_DELAY);
      PORTB = _BLACK;
      delayMicroseconds(FRONTPORCH_PERIOD);
    }
   
   /// following the TV paint assignment, which contradicts the other pdf
   /// but does suggest timing can be way off as long as it's consistent
   /// that means most important thing is match timing between this section
   /// and drawing section

    {
      /// this seems to work better just with an all-sync vsync- this is what arduino pong does in pal
      /// but for the purposes of timing with a scope it might be better to put a pulse of black in there.
        
        
        PORTB = _SYNC;
        updateScreen();
        /// too long or short here curves the top of the screen to left or right like macrovision
        delayMicroseconds(VSYNC_LINES*(LINE_PERIOD)+5);
     
      
      /// adding a few PORTB=PORTB delays doesn't screw up the sync that much, they must
      /// be quick
      //PORTB = PORTB;
      /// even a delaymicroseconds(1) isn't that bad, 5 scews it up but in a unique way
      // dissimilar to the crap when I'm doing the frame buffer - it must be accessing the fb
      // in a way that has uneven amount of time...
      
    }
  
}
