/*
 * Copyright 2006 binarymillenium
 * binarymillenium@gmail.com
 *
 * Provided under the terms of the GNU GPL
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */
package binarymillenium.tiles.client;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.Timer;
import com.google.gwt.user.client.ui.*;

import java.lang.Math;

/**
 *  Tiled 3d first person movement
 */
public class Tiles implements EntryPoint {

    private AbsolutePanel panel;

    private FocusPanel focPan;

    private Image sky = new Image("daysky.png");
    private Image ground = new Image("grass.png");
   

    private int mapsize = 100;
    private short[][] map = new short[mapsize][mapsize];


    //private Image left_wall = new Image("left_wall.png");
   
    private int VIEWDEPTH = 11;
    /// actually a little excessive, but the extra memory isn't a big deal
    private int numobjs = (VIEWDEPTH+3)*VIEWDEPTH;
    private Image[] viewobjects = new Image[numobjs];
    

    private int viewx = mapsize/2;
    private int viewy = mapsize/2;

    private int viewdirx = 0;
    private int viewdiry = 1;

     private double dt = 1.0;

    private short TREEKEY = 1;
    private short MOUNTAINKEY= 2;
  
    private int  numtrees = 200;
    private int  nummountains = 100;

  public void populateMap() {
    for (int i = 0; i< numtrees; i++) {
        int x = (int)(Math.random()*(mapsize-5));
        int y = (int)(Math.random()*(mapsize-5));
        map[x][y] = TREEKEY;

        for (int j = 0; j< 4; j++) {
            int ox = (int)(Math.random()*2);
            int oy = (int)(Math.random()*2);
            map[x+ox][y+oy] = TREEKEY;
        }


    }

    for (int i = 0; i< nummountains; i++) {
        int x = (int)(Math.random()*(mapsize-10))+5;
        int y = (int)(Math.random()*(mapsize-10))+5;

        for (int j = 0; j< 10; j++) {
            int ox = (int)(Math.random()*5);
            int oy = (int)(Math.random()*3);
            map[x+ox][y+oy] = MOUNTAINKEY;
        }
    }
  }

    public void initviewobjects()
    {
        int ind = 0;
        for (int i = VIEWDEPTH; i >= 0; i--) {
        
            for (int j = 0-i; j <= i; j++) {
                
                viewobjects[ind] = new Image("blank.png");
                int pixelsize = 512/(2*(i)+1);
                viewobjects[ind].setPixelSize(pixelsize, pixelsize);

                int x = (int) ((j+i)/(2.0*i+1.0)*512.0);
                int y = (int) ((i)/(2.0*i+1.0)*512.0);
    
                panel.add(viewobjects[ind]);
                panel.setWidgetPosition(viewobjects[ind],x, y);
                ind++;
            }
        }

    }


  public void draw() {

    int ind = 0;
    for (int i = VIEWDEPTH; i >= 0; i--) {
        
        for (int j = 0-i; j <= i; j++) {

            int x =0;
            int y =0;

            if (viewdirx == 1) {
                x = viewx + i;
                y = viewy - j;
            } else if (viewdirx == -1) {
                x = viewx - i;
                y = viewy + j;
            } else if (viewdiry == 1) {
                x = viewx + j;
                y = viewy + i;
            } else if (viewdiry == -1) {
                x = viewx - j;
                y = viewy - i;
            }

            /// draw nothing if view pos is off the map
            if        ( (x < 0) || (x >= mapsize) ) {
                viewobjects[ind].setUrl("blank.png");
            } else if ( (y < 0) || (y >= mapsize) ) {
                viewobjects[ind].setUrl("blank.png");
            } else {
                /// draw objects if any
               if    (map[x][y] == TREEKEY ) {

                    viewobjects[ind].setUrl("tree.png");
               } else if (map[x][y] == MOUNTAINKEY ) {

                    viewobjects[ind].setUrl("mountain.png");
              
               } else {
                    viewobjects[ind].setUrl("blank.png");

               }
            }
            ind++;
        }

    }

  }

  public void checkBounds() {
    if (viewx < 0) viewy = 0;
        if (viewy < 0) viewy = 0;
        if (viewx >= mapsize) viewx = mapsize-1;
        if (viewy >= mapsize) viewy = mapsize-1;

  }
  public void onModuleLoad() {

    populateMap();

    Button forward = new Button("forward", new ClickListener() {
      public void onClick(Widget sender) {
        viewx += viewdirx;
        viewy += viewdiry;
        checkBounds();
        draw();
      }
    });
    RootPanel.get().add(forward);

    Button back = new Button("back", new ClickListener() {
      public void onClick(Widget sender) {
        viewx -= viewdirx;
        viewy -= viewdiry;
        checkBounds();
        draw();
      }
    });
    RootPanel.get().add(back);


    Button left = new Button("left", new ClickListener() {
      public void onClick(Widget sender) {
        viewx -= viewdiry;
        viewy -= viewdirx;
        checkBounds();
                draw();
      }
    });
    RootPanel.get().add(left);


    Button right = new Button("right", new ClickListener() {
      public void onClick(Widget sender) {
        viewx += viewdiry;
        viewy += viewdirx;
        checkBounds();
        draw();
      }
    });
    RootPanel.get().add(right);

    Button turnright = new Button("turn right", new ClickListener() {
      public void onClick(Widget sender) {

        if (viewdirx == 1) {
            viewdirx = 0;
            viewdiry = -1;
        }
        else if (viewdirx == -1) {
            viewdirx = 0;
            viewdiry = 1;
        } else if (viewdiry == 1) {
            viewdirx = 1;
            viewdiry = 0;
        }
        else if (viewdiry == -1) {
            viewdirx = -1;
            viewdiry = 0;
        }


        draw();
      }
    });
    RootPanel.get().add(turnright);


    Button turnleft = new Button("turn left", new ClickListener() {
      public void onClick(Widget sender) {

        if (viewdirx == 1) {
            viewdirx = 0;
            viewdiry = 1;
        }
        else if (viewdirx == -1) {
            viewdirx = 0;
            viewdiry = -1;
        } else if (viewdiry == 1) {
            viewdirx = -1;
            viewdiry = 0;
        }
        else if (viewdiry == -1) {
            viewdirx = 1;
            viewdiry = 0;
        }

        draw();
      }
    });

    RootPanel.get().add(turnleft);


    
    focPan = new FocusPanel();
    panel = new AbsolutePanel();
    focPan.add(panel);
    RootPanel.get().add(focPan);

    //left_wall.setSize("256px","256px");

    //focPan.addKeyboardListener(new landerHandler());
    //focPan.addMouseListener(new landerHandler2());
    
    panel.add(sky);
    panel.add(ground);
    panel.setWidgetPosition(ground, 0,512/2);
    
    initviewobjects();
    
    panel.setSize("512px","512px");
    /// how to specify back to front ordering?
    /// order add and set back to front
    /*for (int i = 0; i < back_wall.length; i++) {
        back_wall[i] = new Image("backwall.png");
        panel.add(back_wall[i]);
        panel.setWidgetPosition(back_wall[i], i*100,512/2-50);
    }*/

    //panel.add(left_wall);
    //panel.setWidgetPosition(left_wall, 0,0);

    draw();
    //new AnimationTimer().scheduleRepeating( (int)(dt*1e3) );
  }

  /// this isn't workinf for some reason
  private class landerHandler extends KeyboardListenerAdapter
  {
  
    public void onKeyDown(Widget sender, char keyCode, int modifiers)
      {
          if (keyCode == KeyboardListener.KEY_LEFT) {
          }
      }

      public void onKeyUp(Widget sender, char keyCode, int modifiers)
      {
          if (keyCode == KeyboardListener.KEY_LEFT) {
          }
      }
  }

    private class landerHandler2 extends MouseListenerAdapter
    {
        public void onMouseMove(Widget w, int x, int y)
        {
        }

    }

  /** update the sim */
  private class AnimationTimer extends Timer
  {   public void run()
      {  

      }

  }
}
