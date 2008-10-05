/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
 *
 *  Copyright 2008 Aaron Koblin 
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at 
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
 *  See the License for the specific language governing permissions and
 *  limitations under the License. 
 *
 *//////////////////////////////////////////////////////////////

// OpenGL trickery for point rendering. Buffers make things speedy!

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import javax.media.opengl.GL;



public class VBPointCloud {
  PApplet p;
  GL gl; 
  PGraphicsOpenGL pgl;
  public float pointSize = 3.0f;
  FloatBuffer pos, col;

  public VBPointCloud(PApplet p) {
    this.p = p;
    this.pgl = (PGraphicsOpenGL) p.g; 
    
    //pos = new FloatBuffer();
    //col = new FloatBuffer();
    
  }

/*
  public void loadFloats(float[] points) {
    pos = ByteBuffer.allocateDirect(4 * points.length).order(
    ByteOrder.nativeOrder()).asFloatBuffer();
    pos.put(points);
    pos.rewind();
  }
  */



  public void loadFloats(float[] points, float[] colors) {
    
    pos = ByteBuffer.allocateDirect(4 * points.length).order(
                  ByteOrder.nativeOrder()).asFloatBuffer();
    pos.put(points);
    pos.rewind();
    
    col = ByteBuffer.allocateDirect(4 * colors.length).order(
                    ByteOrder.nativeOrder()).asFloatBuffer();
    col.put(colors);
    col.rewind();
    
   
  }

float inc;
  public void draw() {
    
    inc = inc+ 0.004;
    
    gl = pgl.beginGL();
    
    gl.glClear(GL.GL_DEPTH_BUFFER_BIT);
    
        gl.glPointSize(pointSize);//*noise(inc));
        gl.glEnable(GL.GL_POINT_SMOOTH);
    gl.glDisable(GL.GL_DEPTH_TEST);
    gl.glEnable(GL.GL_BLEND);
    gl.glBlendFunc(GL.GL_DST_ALPHA, GL.GL_SRC_ALPHA);
    //gl.glBlendFunc(GL.GL_SRC_ALPHA,GL.GL_ONE); 
    
    gl.glEnableClientState(GL.GL_VERTEX_ARRAY);
    gl.glEnableClientState(GL.GL_COLOR_ARRAY);
    
     
   
    //GL doesnt take Processing's color values ... so I'm doin it here!
    //int c = p.g.strokeColor;
   
    //float div = 1.0; //(1.0-(index-i)/(10*1.5));
    
   // gl.glColor4f(p.red(c)/255f*div,p.green(c)/255f*div,p.blue(c)/255f*div,p.alpha(c)/255f*div);
  
    
  gl.glVertexPointer(3, GL.GL_FLOAT, 0, pos);
  gl.glColorPointer(4, GL.GL_FLOAT, 0, col);
 
    
    gl.glDrawArrays(GL.GL_POINTS, 0, numpoints); //f.capacity() / 3);    
    
    
    gl.glDisableClientState(GL.GL_COLOR_ARRAY);
    gl.glDisableClientState(GL.GL_VERTEX_ARRAY);
    pgl.endGL();
  }
}
