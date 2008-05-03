#ifndef FGRXTX_HPP
#define FGRXTX_HPP

#include <cmath>
#include <iostream>
#include <fstream>


#include "net_fdm.hxx"
#include "net_ctrls.hxx"


/// doesn't work if beyond a single t away
#define WRAP(x,t) {if ((x) > (t)) (x) = 2*(t)-(x); if ((x) < -(t)) (x) = 2.0+(x);}
#define CLAMP(x,t) {if ((x) > (t)) (x) = (t);  if ((x) < -(t)) (x) = -(t); }

#define M2FT 3.2808399
//#define M_PI 3.14592

const double start_longitude = -2.1355;
const double start_latitude = 0.656384;
const double EARTH_RADIUS_METERS = 6.378155e6;
const double D2R = M_PI/180.0;
const double ARCM2R = D2R/60.0;



struct known_state {
	double longitude;
	double latitude;
	double altitude;

	double target_long;
	double target_lat;
	double target_alt;

	/// distance from target
	/// this should actually be distance from fixed 0 point since target might move
	float tdx;
	float tdy;

	float error_heading; /// degrees
	float derror_heading; /// filtered
	float ierror_heading;

	float pitch;
	
	float error_pitch;
	float dpitch;  // these are for error_pitch
	float ipitch;

	float tpitch;  // target pitch
	float speed;
	double tdist;  // direct distance to target

	float p;
	float q;
	float r;

	float dq; // derivative of q (filtered)
	float iq;  // integral of q

	float dr;
	float ir;

	float A_X_pilot;
	float A_Y_pilot;
	float A_Z_pilot;
	
	/// acceleration derived orientation
	float acc_orientation;
	///
};

/// 12 bits of fraction precision
const signed int FIX1 = 1<<12;


struct known_state_ints
{
	
	signed int longitude;
	signed int latitude;
	signed int altitude;

	signed int target_lat;  /// degrees in 12bit fixed
	signed int target_long; /// degrees in 12bit fixed
	signed int target_alt;  /// feet in standard int


	/// distance from target
	/// this should actually be distance from fixed 0 point since target might move
	signed int tdx;
	signed int tdy;

	signed int heading;
	signed int target_heading;

	signed int error_heading; /// degrees
	signed int derror_heading; /// filtered
	signed int ierror_heading;

	signed int pitch;
	
	signed int error_pitch;
	signed int dpitch;  // these are for error_pitch
	signed int ipitch;

	signed int tpitch;  // target pitch
	signed int speed;  // ft/s
	signed int tdist;  // direct distance to target

	signed int p;
	signed int q;
	signed int r;

	signed int dq; // derivative of q (filtered)
	signed int iq; // integral of q

	signed int dr;
	signed int ir;

	signed int elevator;

	signed int A_X_pilot;
	signed int A_Y_pilot;
	signed int A_Z_pilot;

};

class fileNotFound {};

// lose precision
#define FPFIX(x) fixed_to_float(float_to_fixed(x))

signed int float_to_fixed(double val);
signed int float_to_fixed16(double val);
double fixed_to_float(signed int fixed_val);
double fixed_to_float16(signed int fixed_val);

void autopilot_ints(known_state_ints& state, known_state_ints& old_state,
					FGNetFDM& buf, FGNetCtrls& bufctrl);

void autopilot(known_state& state, known_state& old_state,
			   FGNetFDM& buf, FGNetCtrls& bufctrl);

#endif

