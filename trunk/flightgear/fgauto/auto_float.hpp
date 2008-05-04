#ifndef AUTO_FLOAT_HPP
#define AUTO_FLOAT_HPP

#include <cmath>

#include <iostream>
#include <fstream>



/// doesn't work if beyond a single t away
#define WRAP(x,t) {if ((x) > (t)) (x) = 2*(t)-(x); if ((x) < -(t)) (x) = 2.0+(x);}
#define CLAMP(x,t) {if ((x) > (t)) (x) = (t);  if ((x) < -(t)) (x) = -(t); }

#define M2FT 3.2808399
//#define M_PI 3.14592

const double EARTH_RADIUS_METERS = 6.378155e6;
const double EARTH_RADIUS_FEET = EARTH_RADIUS_METERS*M2FT;
const double D2R = M_PI/180.0;
const double ARCM2R = D2R/60.0;





struct known_state {
	///////////////////
	/// sensor values
	double longitude;
	double latitude;
	double altitude;

	float p;
	float q;
	float r;

	float A_X_pilot;
	float A_Y_pilot;
	float A_Z_pilot;

	/// sent from ground, default initial value (proposed landing area?)
	double target_long;
	double target_lat;
	double target_alt;

	/// need more info on this, how to simulate it
	float magnetometer;

	////////////////
	/// derived values
	
	/// distance from target
	/// this should actually be distance from fixed 0 point since target might move
	float tdx;
	float tdy;

	/// distance to target in earth frame ( axis going through north pole
	/// other to out of equator from center of earth)
	float tdx_e;
	float tdy_e;
	float tdz_e;

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

	float dq; // derivative of q (filtered)
	float iq;  // integral of q

	float dr;
	float ir;

	/// acceleration derived orientation
	float acc_orientation;

	/// control outputs - put in different struct?
	float elevator;
	float rudder;
	float aileron;
};
void autopilot(known_state& state, known_state& old_state, float dt);

#endif

