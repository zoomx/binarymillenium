
void sendimage(Server s, String filename) 
{
  
  if (s.clientCount > 0) {
    
    
    FileInputStream fstream;
    //println(filename + " ");
    try {
      fstream = new FileInputStream(filename);
    } catch(IOException e) {
      System.err.println("Caught IOException: " 
                        + e.getMessage());
      return;
    }
  
   File imfile = new File(filename);
   int len = (int)imfile.length();
  
   println("server: index " + index + ", len " + len);
   byte[] buffer = new byte[len];
   
   try {
     fstream.read(buffer);
   } catch(IOException e) {
     System.err.println("Caught IOException: " 
                        + e.getMessage());
      return;
   }
   
   
   
   index++;
    
    s.write("IMST");
    s.write(len & 0xFF);
    s.write((len >> 8) & 0xFF);
    s.write((len >> 16) & 0xFF);
    s.write((len >> 24) & 0xFF);
     
    s.write(buffer);
    
    println("server sent " + len + " + " + 8);
    
  
}

}

