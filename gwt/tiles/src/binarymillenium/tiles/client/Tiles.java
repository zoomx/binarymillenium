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
    
    private AbsolutePanel mappanel;
    private int MAPPANELGRIDSIZE = 11;
    private int MAPPANELSIZE = 110;
    private Image[] mapobjects = new Image[MAPPANELGRIDSIZE*MAPPANELGRIDSIZE];

    private FocusPanel focPan;

    private Image sky = new Image("daysky.png");
    private Image ground = new Image("grass.png");
   

    private int MAPSIZE = 100;
    private short[][] map = new short[MAPSIZE][MAPSIZE];
   
    /// where the player has visited on the map
    private boolean[][] mapvisited = new boolean[MAPSIZE][MAPSIZE];


    //private Image left_wall = new Image("left_wall.png");
   
    private int VIEWDEPTH = 11;
    /// actually a little excessive, but the extra memory isn't a big deal
    private int numobjs = (VIEWDEPTH+3)*VIEWDEPTH;
    private Image[] viewobjects = new Image[numobjs];
    
    private int viewx = MAPSIZE/2;
    private int viewy = MAPSIZE/2;

    private int viewdirx = 0;
    private int viewdiry = 1;

     private double dt = 1.0;

    private short TREEKEY = 1;
    private short MOUNTAINKEY= 2;
  
    private int  numtrees = 200;
    private int  nummountains = 100;

    public void initmappanel() 
    {
        for (int i = 0; i < MAPPANELGRIDSIZE; i++) {
        for (int j = 0; j < MAPPANELGRIDSIZE; j++) {
            int ind = i*MAPPANELGRIDSIZE + j;
            int cellsize = MAPPANELSIZE/MAPPANELGRIDSIZE;
            mapobjects[ind] = new Image("gray.png");
            mapobjects[ind].setPixelSize(cellsize,cellsize);
            mappanel.add(mapobjects[ind]);
            mappanel.setWidgetPosition(mapobjects[ind],i*cellsize,j*cellsize);
        }
        }
    }

  public void populateMap() {
    for (int i = 0; i< numtrees; i++) {
        int x = (int)(Math.random()*(MAPSIZE-5));
        int y = (int)(Math.random()*(MAPSIZE-5));
        map[x][y] = TREEKEY;

        for (int j = 0; j< 4; j++) {
            int ox = (int)(Math.random()*2);
            int oy = (int)(Math.random()*2);
            map[x+ox][y+oy] = TREEKEY;
        }


    }

    for (int i = 0; i< nummountains; i++) {
        int x = (int)(Math.random()*(MAPSIZE-10))+5;
        int y = (int)(Math.random()*(MAPSIZE-10))+5;

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


    /// draw the 3D view
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
            if        ( (x < 0) || (x >= MAPSIZE) ) {
                viewobjects[ind].setUrl("blank.png");
            } else if ( (y < 0) || (y >= MAPSIZE) ) {
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

    mapvisited[viewx][viewy] = true;
    /// draw the map
    for (int i = 0; i < MAPPANELGRIDSIZE; i++) {
    for (int j = 0; j < MAPPANELGRIDSIZE; j++) {
        int ind2 = i*MAPPANELGRIDSIZE + j;

        int x = viewx - MAPPANELGRIDSIZE/2 + i;
        int y = viewy + MAPPANELGRIDSIZE/2 - j;
        
        if (inMap(x,y)) {
            if (mapvisited[x][y]) {
                if    (map[x][y] == TREEKEY ) {
                    mapobjects[ind2].setUrl("maptree.png");
                } else if (map[x][y] == MOUNTAINKEY ) {
                    mapobjects[ind2].setUrl("mapmountain.png");
                } else {
                    mapobjects[ind2].setUrl("green.png");
                }
            } else { 
                mapobjects[ind2].setUrl("gray.png");
            }
        } else {
            mapobjects[ind2].setUrl("blank.png");
        }
    }
    }
  }

    public boolean inMap(int x,int y)
    {
        return (inMap(x) && inMap(y));
    }
    public boolean inMap(int x) 
    {
        if (x < 0) return false;
        if (x > MAPSIZE) return false;
        return true;
    }

  public void checkBounds() {
    if (viewx < 0) viewy = 0;
        if (viewy < 0) viewy = 0;
        if (viewx >= MAPSIZE) viewx = MAPSIZE-1;
        if (viewy >= MAPSIZE) viewy = MAPSIZE-1;

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

    mappanel = new AbsolutePanel();
    panel.add(mappanel);
    panel.setWidgetPosition(mappanel,512,0);
    mappanel.setPixelSize(MAPPANELSIZE,MAPPANELSIZE);
    initmappanel();

    //focPan.addKeyboardListener(new landerHandler());
    //focPan.addMouseListener(new landerHandler2());
    
    panel.add(sky);
    panel.add(ground);
    panel.setWidgetPosition(ground, 0,512/2);
    
    initviewobjects();
    
    panel.setPixelSize(512+MAPPANELSIZE,512);
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
