String rxfilename;

String input = new String("1234");
int totalcount = 0;
OutputStream output;
int imind = 0;
int len = 0;
boolean rximage = false;

boolean recvimage(Client c) 
{ 
  boolean rv = false;
  
  int num = c.available();
  if (num > 0) {
   // println("client: num " + num);

    if ((rximage == false) && (num >= 8)) {

      char data[] = {
        c.readChar(),c.readChar(),c.readChar(),c.readChar()      };
      input = new String(data);

      println(input); 

      if (input.equals("IMST")) {
        
        rximage = true;
        imind = 0;
        totalcount = 0;

        int len1 = (int) c.readChar() ;
        int len2 = (int) c.readChar() ;
        int len3 = (int) c.readChar() ;
        int len4 = (int) c.readChar() ;

        print(len1 + ", len " + len2);

        len = len1 + len2*256 + len3*256*256;//len3<<16 + len4<<24;
        rxfilename = "frames/rxim_" + index + ".png";
        output = createOutput(rxfilename);
        
        index++; 

        println("client: expecting " + len + " bytes");

        num -= 8;
      }  
    } 

    if (rximage) {  
      if (num >= (len - totalcount)) {
        num = len-totalcount;
        rximage = false;
        println("client: finished rxing new image");
 
        
        /// return true when we've saved a new image
        rv = true;   
      }

      byte[] byteBuffer = new byte[num];
      int count = c.readBytes(byteBuffer);

      int written = 0;
      try {
        output.write(byteBuffer);//,totalcount,rem);
      } 
      catch (IOException e) {
        println("client: output write failed");
        return false;
      }  

      //println("count " + count + ", num " + num);
      totalcount+=count;
      
      if (len == totalcount) {
        //println("client flushing");
              try {  
          output.flush();
          output.close();
        } 
        catch (IOException e) {
          println("client: output flush and close failed");
        } 
      }
    }
  }
  
  return rv;

}


