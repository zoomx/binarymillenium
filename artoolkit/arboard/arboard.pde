

String cmd[] = {sketchPath("") + "arlaser", sketchPath("") + "images/test1.jpg", 
                sketchPath("")};
//String cmd[] = {"display", sketchPath("") + "images/test1.jpg"};
Process p = exec(cmd);

BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream())); 

String cmdout;

try {
 while ((cmdout = in.readLine()) != null) {
      println(cmdout);
    }
}
catch(IOException e) {
   e.printStackTrace(); 
}
    
if (false) {
in = new BufferedReader(new InputStreamReader(p.getErrorStream())); 


try {
 while ((cmdout = in.readLine()) != null) {
      println(cmdout);
    }
}
catch(IOException e) {
   e.printStackTrace(); 
}
//println(dataPath(""));
}
