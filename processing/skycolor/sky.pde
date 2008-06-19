/*
 * Copyright (C) 2006-2008 binarymillenium	
 *
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Mir is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */


class sun {
   float xyz[];
  float radius;
  

 
  sun(float x,float y, float z, float radius) {
      xyz = new float[3];
      xyz[0] = x;
      xyz[1] = y;
      xyz[2] = z;
      
      this.radius = radius;
  } 
  sun() {
       xyz = new float[3];

  }  
}

class sky {
  
    float g = 0.44;
  float turbidity = 1.027;//1.5;
  
  float gain = 1.0;

  PImage a;

  static final int SZ = 50;
  
  final float maxLong = PI;
  final float minLong =-maxLong;
  final float maxLat = 2*PI;
  final float minLat = PI;

  float colors[][][];
  float coords[][][];
  
  sun suns[];


  static final float earthRadius = 6.38e6;

  // wavelength in nm
  float wlRed = 650; 
  //float wlGreen = 610; 
  float wlGreen = 610; 
  float wlBlue = 475; 
  
  
  /// sky radius
  final float radius = earthRadius+1e5;

  /// henyey-greenstein phase function

  float hg(float g, float theta)
  {
    float rv;

    float g2 = g*g;

    rv = (1.0-g2)/(4.0*PI*pow(1.0 + g2 - 2.0*g*cos(theta),1.5));

    return rv;
  }

  float betaMie (float wavelength, float turbidity)
  {
    //float c = (0.6544*turbidity - 0.6510)*10e-16;
    float c = (0.6544*turbidity*((1000+wavelength)/1550) - 0.6510)*10e-16;
    /// see Practical Analytic Model table 2
    /// float k = 0.67;
    float k = 0.677*(5000+wavelength)/(5000+550);
    float bm = 0.434*c*PI*4*(PI*PI)*k/(wavelength*wavelength);
    return bm;
  }

  float[] betaM(float turbidity)
  {
    float rv[] = new float[3];

    /// a much slower result would apply an entire spectrum to a betaMie
    rv[0] = betaMie(wlRed, turbidity);
    rv[1] = betaMie(wlGreen, turbidity);
    rv[2] = betaMie(wlBlue, turbidity);

    return rv;
  }

  float betaMieTheta(float wavelength, float theta, float g, float turbidity)
  {
    float bm = betaMie(wavelength,turbidity) * hg(g, theta);
    return bm;
  }


  float[] betaM(float theta, float g, float turbidity)
  {
    float rv[] = new float[3];

    rv[0] = betaMieTheta(wlRed, theta, g, turbidity);
    rv[1] = betaMieTheta(wlGreen, theta, g, turbidity);
    rv[2] = betaMieTheta(wlBlue, theta, g, turbidity);

    return rv;
  }

  float betaRayleigh(float wavelength)
  {
    float w4= pow(wavelength,4);
    float pi3 = (PI*PI*PI);
    float n = 1.0008;  /// refractive index
    float N = 1.0;   /// density 

    float br = 8.0*pi3*pow((n*n-1.0),2.0)/(3.0*N*w4);	
    return br;
  }

  float betaRayleighTheta(float wavelength, float theta)
  {
    float cos2theta = pow(cos(theta),2.0);
    float br = (3.0/(16.0*PI)) * betaRayleigh(wavelength) * (2.0 + 0.5*cos2theta);
    return br;
  }

  float[] betaR()
  {
    float rv[] = new float[3];

    rv[0] = betaRayleigh(wlRed);
    rv[1] = betaRayleigh(wlGreen);
    rv[2] = betaRayleigh(wlBlue);

    return rv;				
  }

  float[] betaR(float theta)
  {
    float rv[] = new float[3];

    rv[0] = betaRayleighTheta(wlRed, theta);
    rv[1] = betaRayleighTheta(wlGreen, theta);
    rv[2] = betaRayleighTheta(wlBlue, theta);

    return rv;
  }

  /// aerosol density
  float mieDensity(float alt)
  {
    return exp(-alt/5000.0);
  }

  /// molecular density
  float rayleighDensity(float alt)
  {
    return exp(-alt/15000.0);
  }


  float[] skyColor(float[] sunIntensity, float alt, float depth, float theta, float turbidity, float g)
  {	
    /// simple avg to find optical depths, the density at the final
    /// point is always 0 because it's the edge of the atmosphere
    float sr = depth*rayleighDensity(alt)/2.0;
    float sm = depth*mieDensity(alt)/2.0;
    /// scale the results
    sr *= 15e13;
    sm *= 2e13;

    /// rayleigh is usually the overal sky color, not too dependent on sun position
    /// mie causes brightness near the sun
    float fr = 3e-6;
    float fm = 1.0;
    float br[] = betaR();
    br[0] *= fr;
    br[1] *= fr;
    br[2] *= fr;
    float bm[] = betaM(turbidity);
    bm[0] *= fm;
    bm[1] *= fm;
    bm[2] *= fm;

    float brt[] = betaR(theta);
    brt[0] *= fr;
    brt[1] *= fr;
    brt[2] *= fr;
    /// g effects how sharply intensity ramps up near the sun - it should go up when theta is small
    /// and when altitude is high, but for now keep constant
    float bmt[] = betaM(theta, g, turbidity);
    bmt[0] *= fm;
    bmt[1] *= fm;
    bmt[2] *= fm;

    /// inscattering
    float lin[] = new float[3] ;
    for (int i = 0; i < 3; i++) {
      lin[i] = (brt[i]+bmt[i])/(br[i]+bm[i]) 
        * sunIntensity[i] 
          * (1.0 - exp(-(br[i]*sr + bm[i]*sm)));
    }

    //std::cout << "alt " << alt << ",sr " <<  sr << ", sm " << sm << " " << std::endl;
    //std::cout << "br " << (br*sr).length() << " bm " << (bm*sm).length()  << std::endl;
    //			<< ",sumt " << (brt+bmt).length() << ", sum " << (br+bm).length()
    //			<< ", div " << (brt+bmt).length()/(br+bm).length()  << std::endl;
    return lin;
  }


sky()
{

  final int numSuns = 0;

  suns = new sun[numSuns];

  for (int sunInd= 0; sunInd< suns.length; sunInd++) {
    float longitude = random(2.0*PI);
    float latitude  = random(PI/5.0);
    float sunRadius = radius/60.0;//   (rand()%100/1e2) *radius/40;

    suns[sunInd] = new sun(radius*sin(latitude)*cos(longitude),
                           radius*sin(latitude)*sin(longitude),
                           radius*cos(latitude),
                           sunRadius);
  }

  a = new PImage();
  a.width = SZ;
  a.height = SZ;
  a.pixels = new color[a.width*a.height];
  //colors = new float[SZ][SZ][3];
  coords = new float[SZ][SZ][3];
  
  compute(); 
}





  void compute() {
    
    float maxI = 0;
    
      float viewpos[] = new float[3];
  viewpos[0] = radius*0.0;
  viewpos[1] = radius*0.0;
  viewpos[2] = earthRadius;
    
    colors = new float[SZ][SZ][3];

    float iSize = (maxLong-minLong)/SZ;
    float jSize = (maxLat-minLat)/SZ;
    
    for (int i = 0; i < SZ; i++) {
      for (int j = 0; j < SZ; j++) {    
        
        float latitude = 0;
        float longitude = 0;

        longitude = (float)(i*iSize)+minLong;
        latitude  = (float)(j*jSize)+minLat;

        if (false) {
          /// add jitter to lat long to make them less regular
          if ((i != 0) && (i != (SZ-1)))
            latitude +=  random(iSize/2) - iSize/4.0;

          if ((j != 0) && (j != (SZ-1)))
            longitude += random(jSize/2) - jSize/4.0;
        }

        if (false) {
          for (int sunInd= 0; sunInd< suns.length; sunInd++) {
            colors[i][j][0] = 0.5;  
            colors[i][j][1] = latitude/jSize; 
            colors[i][j][2] = longitude/iSize; 
            colors[i][j][3] = 1.0;
          }
        }

        float h;

        /// make a sphere
        if (true) {

          h = radius;

          float longitudeTemp = h*sin(latitude)*cos(longitude);
          float latitudeTemp = h*sin(latitude)*sin(longitude);
          float hTemp = h*cos(latitude);

          h = hTemp;
          longitude = longitudeTemp;
          latitude = latitudeTemp;
        }

        float skyPoint[] = new float[3];
        skyPoint[0] = longitude;
        skyPoint[1] = latitude;
        skyPoint[2] = h;

        
        float skydir[] = new float[3];
        skydir[0] = skyPoint[0]-viewpos[0];
        skydir[1] = skyPoint[1]-viewpos[1];
        skydir[2] = skyPoint[2]-viewpos[2];
        
        float opticalDepth = dist(0,0,0,skydir[0],skydir[1],skydir[2]);
        float alt = dist(0,0,0,viewpos[0],viewpos[1],viewpos[2])-earthRadius;

        float sunIntensity[] = new float[3];
        float sif= 0.5;
        sunIntensity[0] = 12.0*sif;
        sunIntensity[1] = 12.0*sif;
        sunIntensity[2] = 10.0*sif;

      


        if (false) {
          colors[i][j][0] += 0.8*opticalDepth;  
          colors[i][j][1] += 0.8*opticalDepth; 
          colors[i][j][2] += 2.5*opticalDepth; 
        }

        for (int sunInd= 0; sunInd < suns.length; sunInd++) {

          float sunPoint[] = new float[3];
          sunPoint[0] = suns[sunInd].xyz[0];
          sunPoint[1] = suns[sunInd].xyz[1];
          sunPoint[2] = suns[sunInd].xyz[2];

          float sundir[] = new float[3];
          sundir[0] = (sunPoint[0]-viewpos[0]);
          sundir[1] = (sunPoint[1]-viewpos[1]);
          sundir[2] = (sunPoint[2]-viewpos[2]);
          
          float sundist = dist(sunPoint[0],sunPoint[1],sunPoint[2], viewpos[0], viewpos[1],viewpos[2]);
          float skydirdist = dist(0,0,0,skydir[0],skydir[1],skydir[2]);
          
          /// radians
          float dotprod = (sundir[0]/sundist)*(skydir[0]/skydirdist)+ 
                          (sundir[1]/sundist)*(skydir[1]/skydirdist)+
                          (sundir[2]/sundist)*(skydir[2]/skydirdist);
                          
          float angle = acos(dotprod);	
          //float angleFraction = 2.0*( (1.0-fabs(angle/M_PI))-0.5);
          //float g = 0.8;

          float angleFraction = hg(g, angle);

          //std::cout << angle*180.0/M_PI << " " << angleFraction << std::endl;

          float sky[] = skyColor(sunIntensity, alt, opticalDepth, angle, turbidity, g);
          colors[i][j][0] += sky[0];
          colors[i][j][1] += sky[1];
          colors[i][j][2] += sky[2];


          if (false) 
            /// brightening towards sun
          {
            float minc = 0;
            float f = 0.2/g;
            //angleFraction = angleFraction*angleFraction;
            colors[i][j][0] += f*angleFraction+minc;  
            colors[i][j][1] += f*angleFraction+minc;  
            colors[i][j][2] += f*angleFraction+minc;  
          }	



          if (false) {
            float minc = 0.2;
            float f = 0.5/g;
            if (angleFraction > 0) {
              //angleFraction = angleFraction*angleFraction;
              colors[i][j][0] += f*angleFraction+minc;  
              colors[i][j][1] += f*angleFraction+minc;  
              colors[i][j][2] += f*angleFraction+minc;  
            } 
            else {
              //angleFraction = angleFraction*angleFraction;
              angleFraction = -angleFraction;
              colors[i][j][0] += f*(angleFraction)+minc;  
              colors[i][j][1] += f*(angleFraction)+minc;  
              colors[i][j][2] += f*(angleFraction)+minc;  

            }
          }

          /// highlight sun
          if (false) {
          float skydist = dist(sunPoint[0],sunPoint[1],sunPoint[2],skyPoint[0],skyPoint[1],skyPoint[2]);

          if (skydist < suns[sunInd].radius) {
            colors[i][j][0] += 100.0;  
            colors[i][j][1] = 0.0;  
          } 
          


          else if (false) {
            float sunRadius = suns[sunInd].xyz[3];
            float factor = (skydist-sunRadius)/sunRadius;
            float blendf = 3.0;

            if (factor < 12.0) {
              float intensity = (1.0-factor/12.0);
              intensity*= intensity;
              if (intensity > colors[i][j][1]) colors[i][j][1] = intensity 
                + colors[i][j][1]/blendf;
              else colors[i][j][1] += intensity/blendf;
            } 
            else 
              if (factor < 14.0) {
              float intensity = (1.0-factor/14.0);
              intensity*= intensity;
              if (intensity > colors[i][j][0]) colors[i][j][0] = intensity
                + colors[i][j][0]/blendf;
              else colors[i][j][0] += intensity/blendf;
            } 
            else if (factor < 25.0) {
              float intensity = (1.0-factor/25.0);
              intensity*= intensity;

              if (intensity > colors[i][j][2]) colors[i][j][2] = intensity 
                + colors[i][j][2]/blendf;
              else colors[i][j][2] += intensity/blendf;
            }
          }
          }

          if (false) 
            /// whitening towards horizon, blue towards zenith
            /// also dim previously added colors
          {
            float dim = 0.6;
            float rf = (1.0-exp(-1.0*opticalDepth));
            float gf = (1.0-exp(-1.3*opticalDepth));
            float bf = (1.0-exp(-1.5*opticalDepth));
            colors[i][j][0] += rf
              - colors[i][j][0]*(1.0-rf)*dim;  
            colors[i][j][1] += gf
              - colors[i][j][1]*(1.0-gf)*dim;  
            colors[i][j][2] += bf
              - colors[i][j][2]*(1.0-bf)*dim;  

          }

          coords[i][j][0] = skyPoint[0];
          coords[i][j][1] = skyPoint[1];
          coords[i][j][2] = skyPoint[2];
                 

          for (int k = 0; k <2; k++) {
            if (colors[i][j][k] > maxI) maxI = colors[i][j][k]/gain;
          }

        }
      }

    }
    
    
    
        
    for (int i = 0; i < SZ; i++) {
      for (int j = 0; j < SZ; j++) { 
          int rc = (int) (colors[i][j][0]/maxI*255);
          int gc = (int) (colors[i][j][1]/maxI*255);
          int bc = (int) (colors[i][j][2]/maxI*255);
          a.pixels[(j)*SZ+i] = color(rc,gc,bc);
          
    }}
    
    
  }


void draw() {
    beginShape();
  texture(a);
  vertex(0, 0, 0, 0);
  vertex(width, 0, a.width, 0);
  vertex(width, height, a.width, a.height);
  vertex(0, height, 0, a.height);
  endShape();
}


void newSun(int x, int y)
{
 
  float longitude = (float)x/width*(maxLong-minLong) + minLong;
  float latitude  = (float)y/height*(maxLat-minLat)  + minLat;
  float sunRadius = radius/60.0; 
  
  
  print(longitude +  " " + latitude + "\n");
  
   sun nsun = new sun(radius*sin(latitude)*cos(longitude),
                           radius*sin(latitude)*sin(longitude),
                           radius*cos(latitude),
                           sunRadius);
  
  sun ssuns[] = new sun[suns.length+1];
  
  for (int i = 0;i <suns.length; i++ ) {
     ssuns[i] = suns[i]; 
  }
  ssuns[suns.length] = nsun;
 
  
  suns = ssuns;
 
  compute();
}

void replaceSun(int x, int y) {
  {
 
  float longitude = (float)x/width*(maxLong-minLong) + minLong;
  float latitude  = (float)y/height*(maxLat-minLat)  + minLat;
  float sunRadius = radius/60.0; 
  
  
  print(longitude +  " " + latitude + "\n");
  
   sun nsun = new sun(radius*sin(latitude)*cos(longitude),
                           radius*sin(latitude)*sin(longitude),
                           radius*cos(latitude),
                           sunRadius);
  
  sun ssuns[] = new sun[1]; //suns.length+1];
  
  //for (int i = 0;i <suns.length; i++ ) {
  //   ssuns[i] = suns[i]; 
  //}
 // ssuns[suns.length] = nsun;
  ssuns[0] = nsun;
  
  suns = ssuns;
 
 //ssuns = append(ssuns, nsun);
  compute();
}
}

}


