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


class spectrum {
  
  	static final unsigned SIZE = 200;

	/// nanometers  
	/// visible light only spans 400-700 nm, but I want some margin
	static final float minWavelength = 200.0;
	static final float maxWavelength = 1000.0;


	

	float[] intensities;

spectrum()
{
	intensities.resize(SIZE);
	
	for (unsigned i = 0; i < intensities.size(); i++) {
		intensities[i] = 1.0;
	}
}


unsigned wavelengthToIndex(float wavelength) 
{
	return (unsigned)(SIZE*(wavelength-minWavelength)/(maxWavelength-minWavelength));

}

float indexToWavelength(unsigned index) 
{
	return (float)index/(float)SIZE*(maxWavelength-minWavelength) + minWavelength;

}

}
