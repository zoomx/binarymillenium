/// binarymillenium April 2010
/// GPL 3.0 

String pi1000 = "3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067982148086513282306647093844609550582231725359408128481117450284102701938521105559644622948954930381964428810975665933446128475648233786783165271201909145648566923460348610454326648213393607260249141273724587006606315588174881520920962829254091715364367892590360011330530548820466521384146951941511609433057270365759591953092186117381932611793105118548074462379962749567351885752724891227938183011949129833673362440656643086021394946395224737190702179860943702770539217176293176752384674818467669405132000568127145263560827785771342757789609173637178721468440901224953430146549585371050792279689258923542019956112129021960864034418159813629774771309960518707211349999998372978049951059731732816096318595024459455346908302642522308253344685035261931188171010003137838752886587533208381420617177669147303598253490428755468731159562863882353787593751957781857780532171226806613001927876611195909216420198";


// advance every timestep and some speed
boolean timeredRun = true;

/// restart if any failure if 0
/// set to negative to disable (allow any amount of failures)
int failuresAllowed = -1;
int minPercentage = 50;

final int MAX_IND = 100;

int x = 30;
PFont fontA;

int index;

// the
int numConsecutive;
int numRight;
// the number of attempts- not just the number of digits tried
// but the number of keys pressed even multiple for a single digit
int numTried;

/// current digit (or decimal)
char curKey;

int percentage = 100;

void setup() 
{
  size(200, 200);
  background(102);

  // Load the font. Fonts must be placed within the data 
  // directory of your sketch. Use Tools > Create Font 
  // to create a distributable bitmap font. 
  // For vector fonts, use the createFont() function. 
  fontA = loadFont("Serif.plain-48.vlw");

  // Set the font and its size (in units of pixels)
  textFont(fontA, 48);
 
  frameRate(1);
  
}

void restart()
{
  background(255);
  //println("restart");
  index = 0;
  numConsecutive = 0;
  numRight = 0;
  numTried = 0;
  percentage = 100;
    
}

void keyPressed()
{
  if (key == curKey) {
    numConsecutive++;
    numRight++;
    if (!timeredRun) {
      index++; 
    }
  }  else {
     numConsecutive = 0; 
  }
   numTried++;
   

}

void draw() {
  
    if (numTried > 0)
     percentage = (int)(100*(float)numRight/(float)numTried);
   

  
  
  background(128);
  if ((index+1 >= pi1000.length()) || ( index >= MAX_IND)) {
    //numRight = 0;
    index= 0;
    
  }
  // Use fill() to change the value or color of the text
  fill(0);
  curKey = pi1000.charAt(index);
  textFont(fontA, 48);
   
  for (int i = index-10; (i < index+10) && (i < MAX_IND) && (i < pi1000.length()); i++) {
    
    if (i < index) fill(200-(index-i+2)*20);
    else if (i == index) {
      fill(230,255,230);
    }
    else fill(50,200-(i-index)*10,120-(i-index)*5);
    if (i >= 0) {
        
      text(pi1000.substring(i,i+1), width/2+(i-index)*18, height/2);
    }
  }
  
  if (timeredRun) {
    index++;
    /// TBD increment numTried unless it has been incremented this turn already
    // and count as failure if no keypress.
  }
  
  /// TBD need to mix colors in using both min Percentage and
  /// max failures- turn red if any are marginal.
  float dp = 1.0-(float)(percentage-minPercentage)/(float)(100-minPercentage);
  fill(100 + dp*155,235-dp*235,200-dp*200);
  textFont(fontA, 28);
  String disp = "" + percentage + "%";
  //println(disp);
  text(disp, width/2, height/4);
      
  String run = "" + numConsecutive;
  //println(disp);
  text(run, width/2, height/4-20);
    
    
   if (percentage < minPercentage) {
      restart(); 
   }
   
   if ((failuresAllowed > 0) && (numTried - numRight >= failuresAllowed)) {
      restart(); 
   }
}



