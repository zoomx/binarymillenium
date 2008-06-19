7/*
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


/// Approximate RGB values for Visible Wavelengths
/// http://www.physics.sfasu.edu/astro/color/spectra.html


class spectrum {
  
  static final int SIZE = 200;

  /// nanometers  
  /// visible light only spans 400-700 nm, but I want some margin
  static final float minWavelength = 200.0;
  static final float maxWavelength = 1000.0;

  float[] intensities;

  spectrum() {
    intensities = new float[SIZE];

    for (int i = 0; i < SIZE; i++) {
      intensities[i] = 1.0;
    }
    
  }
  
   int  wavelengthToIndex(final float wavelength)  
{
  return (int)(SIZE*(wavelength-minWavelength)/(maxWavelength-minWavelength));

}

float indexToWavelength(final int index)
{
  return (float)index/(float)SIZE*(maxWavelength-minWavelength) + minWavelength;

}

}




class colorOps{
  
  spectrum reds, greens, blues;
   
colorOps() {
   reds   = new spectrum();
   greens = new spectrum();
   blues  = new spectrum();

	/// make colors
	for (int i = 0; i< reds.intensities.length; i++) {
		float w = reds.indexToWavelength(i);	
		
                /// this is a rough approximation of the eye sensitivty 
                /// typical color chart http://en.wikipedia.org/wiki/Image:Cones_SMJ2_E.svg
		if ((w >= 340.0) && (w < 380.0)) {
			
			reds.intensities[i] = (w-340.0)/(380.0-340.0);
			greens.intensities[i] = 0.0;
			blues.intensities[i] = 0.0;

		} else if ((w > 380.0) && (w < 440.0)) {

			reds.intensities[i] = -(w-440.0)/(440.0-380.0);
			greens.intensities[i] = 0.0;
			blues.intensities[i] = 1.0;

		} else if ((w >= 440.0) && (w < 490.0)) {
			
			reds.intensities[i] = 0.0;
			greens.intensities[i] = (w-440.0)/(490.0-440.0);
			blues.intensities[i] = 1.0;

		} else if ((w >= 490.0) && (w < 510.0)) {
			
			reds.intensities[i] = 0.0;
			greens.intensities[i] = 1.0;
			blues.intensities[i] = -(w-510.0)/(510.0-490.0);

		} else if ((w >= 510.0) && (w < 580.0)) {
			
			reds.intensities[i] = (w-510.0)/(580.0-510.0);
			greens.intensities[i] = 1.0;
			blues.intensities[i] = 0.0;

		} else if ((w >= 580.0) && (w < 645.0)) {
			
			reds.intensities[i] = 1.0;
			greens.intensities[i] = -(w-645.0)/(645.0-580.0);
			blues.intensities[i] = 0.0;

		} else if ((w >= 645.0) && (w < 780.0)) {
			
			reds.intensities[i] = 1.0;
			greens.intensities[i] = 0.0;
			blues.intensities[i] = 0.0;

		} else if (w >= 780.0) {
			
			reds.intensities[i] = -(w-800.0)/(800.0-780.0);
			greens.intensities[i] = 0.0;
			blues.intensities[i] = 0.0;

		}
	}

}

float[] spectrumToRGB(spectrum theSpectrum)
{	
  float rv[] = new float[3];
  
  rv[0] = sum(mult(reds,theSpectrum));
  rv[1] = sum(mult(greens,theSpectrum)); 
  rv[2] = sum(mult(blues,theSpectrum));  
        
  return rv;
}


spectrum mult(spectrum l, spectrum r)
{
	spectrum rv = new spectrum();
	
	if (l.intensities.length != r.intensities.length) return rv;

	for (int i = 0; i < l.intensities.length; i++) {
		rv.intensities[i] = l.intensities[i] * r.intensities[i];
	}

	return rv;
}

spectrum mult(spectrum l, float r)
{
	spectrum rv = new spectrum();
	
	for (int i = 0; i < l.intensities.length; i++) {
		rv.intensities[i] = l.intensities[i] * r;
	}

	return rv;
}


float sum(spectrum l)
{	
	float rv = 0.0;
	for (int i = 0; i < l.intensities.length; i++) {
		rv += l.intensities[i];
	}
	return rv;
}

}
