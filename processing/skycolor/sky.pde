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



class sky {
  
  static final float earthRadius = 6.38e6;
  
		// wavelength in nm
		float wlRed = 650; 
		//float wlGreen = 610; 
		float wlGreen = 610; 
		float wlBlue = 475; 

/// henyey-greenstein phase function
	
	float hg(float g, float theta)
	{
		float rv;

		float g2 = g*g;

		rv = (1.0-g2)/(4.0*M_PI*pow(1.0 + g2 - 2.0*g*cos(theta),1.5));

		return rv;
	}

	float betaMie (float wavelength, float turbidity)
	{
		//float c = (0.6544*turbidity - 0.6510)*10e-16;
		float c = (0.6544*turbidity*((1000+wavelength)/1550) - 0.6510)*10e-16;
		/// see Practical Analytic Model table 2
		/// float k = 0.67;
		float k = 0.677*(5000+wavelength)/(5000+550);
		float bm = 0.434*c*M_PI*4*(M_PI*M_PI)*k/(wavelength*wavelength);
		return bm;
	}

	osg::Vec3 betaM(float turbidity)
	{
		return osg::Vec3(
				betaMie(wlRed, turbidity),
				betaMie(wlGreen, turbidity),
				betaMie(wlBlue, turbidity)
				);
	}

	float betaMieTheta(float wavelength, float theta, float g, float turbidity)
	{
		float bm = betaMie(wavelength,turbidity) * hg(g, theta);
		return bm;
	}


	osg::Vec3 betaM(float theta, float g, float turbidity)
	{
		return osg::Vec3(
				betaMieTheta(wlRed, theta, g, turbidity),
				betaMieTheta(wlGreen, theta, g, turbidity),
				betaMieTheta(wlBlue, theta, g, turbidity)
				);
	}

	float betaRayleigh(float wavelength)
	{
		float w4= pow(wavelength,4);
		float pi3 = (M_PI*M_PI*M_PI);
		float n = 1.0008;  /// refractive index
		float N = 1.0;   /// density 
		
		float br = 8.0*pi3*pow((n*n-1.0),2.0)/(3.0*N*w4);	
		return br;
	}

	float betaRayleighTheta(float wavelength, float theta)
	{
		float cos2theta = pow(cos(theta),2.0);
		float br = (3.0/(16.0*M_PI)) * betaRayleigh(wavelength) * (2.0 + 0.5*cos2theta);
		return br;
	}

	osg::Vec3 betaR(void)
	{
		return osg::Vec3(
					betaRayleigh(wlRed),
					betaRayleigh(wlGreen),
					betaRayleigh(wlBlue)
					);
	}
	
	osg::Vec3 betaR(float theta)
	{
				return osg::Vec3(
					betaRayleighTheta(wlRed, theta),
					betaRayleighTheta(wlGreen, theta),
					betaRayleighTheta(wlBlue, theta)
					);
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


	osg::Vec3 skyColor(osg::Vec3 sunIntensity, float alt, float depth, float theta,
						float turbidity, float g)
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
		osg::Vec3 br = betaR()*fr;
		osg::Vec3 bm = betaM(turbidity)*fm;

		osg::Vec3 brt = betaR(theta)*fr;
		/// g effects how sharply intensity ramps up near the sun - it should go up when theta is small
		/// and when altitude is high, but for now keep constant
		osg::Vec3 bmt = betaM(theta, g, turbidity)*fm;

		/// inscattering
		osg::Vec3 lin;
		for (unsigned i = 0; i < 3; i++) {
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
}

sky::sky()
{

	base = new osg::PositionAttitudeTransform;

	/// sky radius
	const float radius = earthRadius+1e5;

	const int numSuns = 1;

    osg::Vec4Array& suns = *(new osg::Vec4Array(numSuns));

	osg::Vec3 viewpos = osg::Vec3(radius*0.0,radius*0.0,earthRadius);

	for (int sunInd= 0; sunInd< numSuns; sunInd++) {
		float longitude = (rand()%1000)/1e3 * 2.0*M_PI;
		float latitude  = (rand()%1000)/1e3  * M_PI/5.0;
		float sunRadius = radius/60.0;//   (rand()%100/1e2) *radius/40;
		
		suns[sunInd][0] = radius*sin(latitude)*cos(longitude);
		suns[sunInd][1] = radius*sin(latitude)*sin(longitude);
		suns[sunInd][2] = radius*cos(latitude);
		suns[sunInd][3] = sunRadius;

	}

	if (1) {
		/// length of the center square on a side will be 2^n
		const int n = 6;
		const int iSize = (int)pow(2, n);
		const int jSize = (int)pow(2, n);

		//int gridxsize = (n-3)*2+1;
		int gridxsize = 3;	
		//int gridysize = (n-3)*2+1;
		int gridysize = 3;

		int gridxmid = gridxsize/2;
		int gridymid = gridysize/2;


		//////////////////////////////


		for (int i = 0; i < gridxsize; i++) {
			for (int j = 0; j < gridysize; j++) {

				osg::Geometry* geom = new osg::Geometry;

				int xres = 1<<n;
				int yres = 1<<n;

				osg::Vec3Array& coords = *(new osg::Vec3Array(xres*yres));
				osg::Vec4Array& colors = *(new osg::Vec4Array(xres*yres));

				int ci = 0;

				for (int x = 0; x < xres; x++) {
					for (int y = 0; y < yres; y++) {

						float latitude = 0;
						float longitude = 0;

						longitude = (float)(i*(iSize-1) + x*(iSize/(xres)));
						latitude  = (float)(j*(jSize-1) + y*(jSize/(yres)));

#if 0
						/// add jitter to lat long to make them less regular
						if ((i != 0) && (i != (imax-1)))
							latitude +=  ((rand()%100)/1e2)*istep - istep/2.0;

						if ((j != 0) && (j != (jmax)))
							longitude +=  ((rand()%100)/1e2)*jstep - jstep/2.0;
#endif

						#if 0
						for (int sunInd= 0; sunInd< numSuns; sunInd++) {
							colors[ci][0] = 0.5;  
							colors[ci][1] = latitude/jSize; 
							colors[ci][2] = longitude/iSize; 
							colors[ci][3] = 1.0;
						}
						#endif

						float h;

						/// make a sphere
						if (1) {
							longitude = longitude/(gridxsize*(iSize-1)) * 2.0*M_PI;
							latitude  = latitude/(gridysize*(jSize-1)) * M_PI/3.0;

							h = radius;

							float longitudeTemp = h*sin(latitude)*cos(longitude);
							float latitudeTemp = h*sin(latitude)*sin(longitude);
							float hTemp = h*cos(latitude);

							h = hTemp;
							longitude = longitudeTemp;
							latitude = latitudeTemp;
						}

						osg::Vec3 skyPoint(longitude, latitude, h);

						colors[ci] = osg::Vec4(0,0,0,1);

						osg::Vec3 skydir = (skyPoint-viewpos);
						float opticalDepth = skydir.length();
						float alt = viewpos.length()-earthRadius;
						osg::Vec3 sunIntensity(12.0,12.0,10.0);
						sunIntensity *= 0.5;
						float g = 0.44;
						float turbidity = 1.5;
#if 0
						colors[ci][0] += 0.8*opticalDepth;  
						colors[ci][1] += 0.8*opticalDepth; 
						colors[ci][2] += 2.5*opticalDepth; 
#endif

						for (int sunInd= 0; sunInd < numSuns; sunInd++) {

							osg::Vec3 sunPoint(suns[sunInd][0],suns[sunInd][1],suns[sunInd][2]);

							osg::Vec3 sundir = (sunPoint-viewpos);
							/// radians
							float dotprod = (sundir/sundir.length())*(skydir/skydir.length());
							float angle = acos(dotprod);	
							//float angleFraction = 2.0*( (1.0-fabs(angle/M_PI))-0.5);
							//float g = 0.8;
							
							float angleFraction = hg(g, angle);
							
							//std::cout << angle*180.0/M_PI << " " << angleFraction << std::endl;

							osg::Vec3 sky = skyColor(sunIntensity, 
												alt, opticalDepth, angle,
												turbidity, g);
							colors[ci][0] += sky[0];
							colors[ci][1] += sky[1];
							colors[ci][2] += sky[2];
												

							#if 0
							/// brightening towards sun
							{
							float min = 0;
							float f = 0.2/g;
								//angleFraction = angleFraction*angleFraction;
								colors[ci][0] += f*angleFraction+min;  
								colors[ci][1] += f*angleFraction+min;  
								colors[ci][2] += f*angleFraction+min;  
							}	
							#endif


							#if 0
							float min = 0.2;
							float f = 0.5/g;
							if (angleFraction > 0) {
								//angleFraction = angleFraction*angleFraction;
								colors[ci][0] += f*angleFraction+min;  
								colors[ci][1] += f*angleFraction+min;  
								colors[ci][2] += f*angleFraction+min;  
							} else {
								//angleFraction = angleFraction*angleFraction;
								angleFraction = -angleFraction;
								colors[ci][0] += f*(angleFraction)+min;  
								colors[ci][1] += f*(angleFraction)+min;  
								colors[ci][2] += f*(angleFraction)+min;  

							}
							#endif

							/// highlight sun
							float dist = (sunPoint-skyPoint).length();

							if (dist < suns[sunInd][3]) {
								colors[ci][0] += 100.0;  
								colors[ci][1] = 0.0;  
							} 
							
#if 0 	
							else {
								float sunRadius = suns[sunInd][3];
								float factor = (dist-sunRadius)/sunRadius;
								float blend = 3.0;

								if (factor < 12.0) {
									float intensity = (1.0-factor/12.0);
									intensity*= intensity;
									if (intensity > colors[ci][1]) colors[ci][1] = intensity 
										+ colors[ci][1]/blend;
									else colors[ci][1] += intensity/blend;
								} 
								else 
									if (factor < 14.0) {
										float intensity = (1.0-factor/14.0);
										intensity*= intensity;
										if (intensity > colors[ci][0]) colors[ci][0] = intensity
											+ colors[ci][0]/blend;
										else colors[ci][0] += intensity/blend;
									} 
									else if (factor < 25.0) {
										float intensity = (1.0-factor/25.0);
										intensity*= intensity;

										if (intensity > colors[ci][2]) colors[ci][2] = intensity 
											+ colors[ci][2]/blend;
										else colors[ci][2] += intensity/blend;
									}
#endif
							}

							#if 0
							/// whitening towards horizon, blue towards zenith
							/// also dim previously added colors
							{
							float dim = 0.6;
							float rf = (1.0-exp(-1.0*opticalDepth));
							float gf = (1.0-exp(-1.3*opticalDepth));
							float bf = (1.0-exp(-1.5*opticalDepth));
							colors[ci][0] += rf
								- colors[ci][0]*(1.0-rf)*dim;  
							colors[ci][1] += gf
								- colors[ci][1]*(1.0-gf)*dim;  
							colors[ci][2] += bf
								- colors[ci][2]*(1.0-bf)*dim;  
							//std::cout << opticalDepth << std::endl;
							}
							#endif
							
							coords[ci] = skyPoint;



						ci++;
					}
				}

				for(int x = 0; x < xres-1; x++ )
				{
					osg::DrawElementsUShort* drawElements = new osg::DrawElementsUShort(osg::PrimitiveSet::TRIANGLE_STRIP);
					drawElements->reserve(38);

					for(int y = 0; y < yres; y++ )
					{
						drawElements->push_back((x+0)*(yres)+y);
						drawElements->push_back((x+1)*(yres)+y);
					}

					geom->addPrimitiveSet(drawElements);
				}

				geom->setVertexArray( & coords );
				geom->setColorArray( &colors );
				geom->setColorBinding( osg::Geometry::BIND_PER_VERTEX );

				osg::Geode *geode = new osg::Geode;
				geode->addDrawable(geom);

				osgUtil::SmoothingVisitor sv;
				sv.smooth(*geom);


				base->addChild(geode);

				osg::StateSet *dstate = new osg::StateSet;
				dstate->setMode( GL_LIGHTING, osg::StateAttribute::OFF );
				dstate->setMode( GL_CULL_FACE, osg::StateAttribute::OFF );
				// clear the depth to the far plane.
				//osg::Depth* depth = new osg::Depth;
				//depth->setFunction(osg::Depth::ALWAYS);
				//depth->setRange(1.0,1.0);
				//dstate->setAttributeAndModes(depth,osg::StateAttribute::ON);
				dstate->setAttributeAndModes(new osg::Fog, osg::StateAttribute::OFF);
				dstate->setRenderBinDetails(-2,"RenderBin");
				geode->setStateSet(dstate);

				}
		}
	}

		
}
