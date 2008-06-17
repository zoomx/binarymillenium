/*
 * Copyright (C) 2006 binarymillenium	
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


#include "colorOps.hpp"
#include "spectrum.hpp"

/// Approximate RGB values for Visible Wavelengths
/// http://www.physics.sfasu.edu/astro/color/spectra.html
colorOps::colorOps()
{

	/// make colors
	for (unsigned i = 0; i< red.intensities.size(); i++) {
		float w = spectrum::indexToWavelength(i);	
		
		if ((w >= 340.0) && (w < 380.0)) {
			
			red.intensities[i] = (w-340.0)/(380.0-340.0);
			green.intensities[i] = 0.0;
			blue.intensities[i] = 0.0;

		} else if ((w > 380.0) && (w < 440.0)) {

			red.intensities[i] = -(w-440.0)/(440.0-380.0);
			green.intensities[i] = 0.0;
			blue.intensities[i] = 1.0;

		} else if ((w >= 440.0) && (w < 490.0)) {
			
			red.intensities[i] = 0.0;
			green.intensities[i] = (w-440.0)/(490.0-440.0);
			blue.intensities[i] = 1.0;

		} else if ((w >= 490.0) && (w < 510.0)) {
			
			red.intensities[i] = 0.0;
			green.intensities[i] = 1.0;
			blue.intensities[i] = -(w-510.0)/(510.0-490.0);

		} else if ((w >= 510.0) && (w < 580.0)) {
			
			red.intensities[i] = (w-510.0)/(580.0-510.0);
			green.intensities[i] = 1.0;
			blue.intensities[i] = 0.0;

		} else if ((w >= 580.0) && (w < 645.0)) {
			
			red.intensities[i] = 1.0;
			green.intensities[i] = -(w-645.0)/(645.0-580.0);
			blue.intensities[i] = 0.0;

		} else if ((w >= 645.0) && (w < 780.0)) {
			
			red.intensities[i] = 1.0;
			green.intensities[i] = 0.0;
			blue.intensities[i] = 0.0;

		} else if (w >= 780.0) {
			
			red.intensities[i] = -(w-800.0)/(800.0-780.0);
			green.intensities[i] = 0.0;
			blue.intensities[i] = 0.0;

		}
	}

}

osg::Vec3 colorOps::spectrumToRGB(spectrum& theSpectrum)
{
	
	float r = sum(mult(red,theSpectrum)); 
	float g = sum(mult(green,theSpectrum)); 
	float b = sum(mult(blue,theSpectrum)); 

	return osg::Vec3(r,g,b);
}


spectrum colorOps::mult(spectrum& l, spectrum& r)
{
	spectrum rv;
	
	if (l.intensities.size() != r.intensities.size()) return rv;

	for (unsigned i = 0; i < l.intensities.size(); i++) {
		rv.intensities[i] = l.intensities[i] * r.intensities[i];
	}

	return rv;

}

spectrum colorOps::mult(spectrum& l, float r)
{
	spectrum rv;
	
	for (unsigned i = 0; i < l.intensities.size(); i++) {
		rv.intensities[i] = l.intensities[i] * r;
	}

	return rv;
}


float colorOps::sum(spectrum l)
{	
	float rv = 0.0;
	for (unsigned i = 0; i < l.intensities.size(); i++) {
		rv += l.intensities[i];
	}
	return rv;
}
