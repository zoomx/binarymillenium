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
#define WIDTH 38
#define HEIGHT 15

byte frameBuffer[WIDTH][HEIGHT+1];

//#define LINE_PERIOD 63.625
#define LINE_PERIOD 63.3
// 63.45 stable but wrong

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
    for (index = 0; index < 2; index++)
      for (index2=0;index2<HEIGHT;index2++)
        {
         frameBuffer[index][index2] = _BLACK;
         
        }
        
}

 int counter = 0;

void updateScreen()
{
      for (index = 0; index < WIDTH; index++) {
      for (index2=0;index2<HEIGHT-1;index2++)
        {
        /*  if (index2 & 0x01)
         frameBuffer[index][index2] = ((counter>>4)+index)%3+1; //(((counter+index2)/10)%3)+1;
         else
         frameBuffer[index][index2] = ((counter>>4)+index+1)%3+1; //(((counter+index2)/10)%3)+1;
         */
         frameBuffer[index][index2] = frameBuffer[index][index2+((counter & 0x11) == 0x11)];
        }
        
        if ((counter>>2 & 0x01))
        frameBuffer[index][index2] = frameBuffer[index][0];
        else
        frameBuffer[index][index2] = frameBuffer[index][0];
      }
  
}

void randomScreen()
{
      for (index = 0; index < WIDTH; index++)
      for (index2=0;index2<HEIGHT;index2++)
        {
         
         frameBuffer[index][index2] = rand()%3+1;
        }
  
}

void setup()                    // run once, when the sketch starts
{
  /// disable the interrupt, this produces a much more steady image 
  /// even if the timing is still wrong
  cli();
  clearScreen();
  int i;
  /*for (i = 0; i < 10; i++) {
    frameBuffer[10][i] = _WHITE;
    frameBuffer[i+5][10] = _GRAY;
  }*/
  
  randomScreen();
  /*
    for (index = 0; index < WIDTH; index++)
      for (index2=0;index2<HEIGHT;++index2)
        {
         frameBuffer[index][index2] = _WHITE;
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
     
     newLine = line >>4;
     
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
       
      
   
      PORTB = frameBuffer[0][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[1][newLine];
      delayMicroseconds(1);
      
      PORTB = frameBuffer[2][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[3][newLine];
      delayMicroseconds(1);
      
      PORTB = frameBuffer[4][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[5][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[6][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[7][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[8][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[9][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[10][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[11][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[12][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[13][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[14][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[15][newLine];
      delayMicroseconds(1);
      
      PORTB = frameBuffer[16][newLine];
      delayMicroseconds(1);
      
      PORTB = frameBuffer[17][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[18][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[19][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[20][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[21][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[22][newLine];
      delayMicroseconds(1);     
      PORTB = frameBuffer[23][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[24][newLine];
      delayMicroseconds(1);     
      PORTB = frameBuffer[25][newLine];
      delayMicroseconds(1);
      
      PORTB = frameBuffer[26][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[27][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[28][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[29][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[30][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[31][newLine];
      delayMicroseconds(1);
      /*
      PORTB = frameBuffer[32][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[33][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[34][newLine];
      delayMicroseconds(1);
      PORTB = frameBuffer[35][newLine];
      delayMicroseconds(1);*/
      
     
      PORTB = _BLACK;
      delayMicroseconds(LINE_PERIOD - SYNC_PERIOD - BACKPORCH_PERIOD - FRONTPORCH_PERIOD-45);
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
        delayMicroseconds(VSYNC_LINES*(LINE_PERIOD)+5);
     
      
      /// adding a few PORTB=PORTB delays doesn't screw up the sync that much, they must
      /// be quick
      //PORTB = PORTB;
      /// even a delaymicroseconds(1) isn't that bad, 5 scews it up but in a unique way
      // dissimilar to the crap when I'm doing the frame buffer - it must be accessing the framebuffer
      // in a way that has uneven amount of time...
      
    }
  
}
