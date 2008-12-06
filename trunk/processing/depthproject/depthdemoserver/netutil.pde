
void sendimage( String filename) 
{
  
  if (srv.clientCount > 0) {
    
    
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
   
   
   
  // index++;
    
    srv.write("IMST");
    srv.write(len & 0xFF);
    srv.write((len >> 8) & 0xFF);
    srv.write((len >> 16) & 0xFF);
    srv.write((len >> 24) & 0xFF);
     
    srv.write(buffer);
    
    println("server sent " + len + " + " + 8);
    
  
}

}

