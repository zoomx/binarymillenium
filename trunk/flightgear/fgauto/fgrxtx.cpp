/*
 * GNU GPL
 *
 * 2008 binarymillenium
 *
 *
 */

#include <stdio.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <netinet/in.h>
#include <errno.h>
#include <time.h>

#define M_PI 3.14592
#include <cmath>

#include <iostream>
#include <fstream>

typedef signed int       int32_t;
typedef unsigned int     uint32_t;

#include "net_fdm.hxx"
#include "net_ctrls.hxx"

/// doesn't work if beyond a single t away
#define WRAP(x,t) {if ((x) > (t)) (x) = 2*(t)-(x); if ((x) < -(t)) (x) = 2.0+(x);}
#define CLAMP(x,t) {if ((x) > (t)) (x) = (t);  if ((x) < -(t)) (x) = -(t); }

#define M2FT 3.2808399

		double target_longitude = -2.137; 
		double target_latitude  = .658;
		double target_altitude  = 0.0; //meters 



const double start_longitude = -2.1355;
const double start_latitude = 0.656384;
const double EARTH_RADIUS_METERS = 6.378155e6;
const double D2R = M_PI/180.0;

struct known_state {
	double longitude;
	double latitude;
	double altitude;

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

	///
};

/// 12 bits of fraction precision
const signed int FIX1 = 1<<12;

signed int float_to_fixed(double val)
{
	return (signed int)(val*FIX1);
}

double fixed_to_float(signed int fixed_val)
{
	return (float)(fixed_val)/(float)(FIX1);
}

/// GPS integer equivalents
/// last 4 bits behind decimal
//const signed int GPS_POS90 = 1<<24;
//const signed int GPS_NEG90 = -GPS_POS90;



struct known_state_ints
{
	
	signed int longitude;
	signed int latitude;
	signed int altitude;

	/// distance from target
	/// this should actually be distance from fixed 0 point since target might move
	signed int tdx;
	signed int tdy;

	signed int error_heading; /// degrees
	signed int derror_heading; /// filtered
	signed int ierror_heading;

	signed int pitch;
	
	signed int error_pitch;
	signed int dpitch;  // these are for error_pitch
	signed int ipitch;

	signed int tpitch;  // target pitch
	signed int speed;
	signed int tdist;  // direct distance to target

	signed int p;
	signed int q;
	signed int r;

	signed int dq; // derivative of q (filtered)
	signed int iq;  // integral of q

	signed int dr;
	signed int ir;

	signed int elevator;

	signed int A_X_pilot;
	signed int A_Y_pilot;
	signed int A_Z_pilot;

};

class fileNotFound {};

void state_fixed_to_float(known_state_ints& state_ints, known_state& state)
{
	state.p = fixed_to_float(state_ints.p);
	state.q = fixed_to_float(state_ints.q);
	state.r = fixed_to_float(state_ints.r);
	
	state.dq = fixed_to_float(state_ints.dq);
	state.dr = fixed_to_float(state_ints.dr);
	state.iq = fixed_to_float(state_ints.iq);
	state.ir = fixed_to_float(state_ints.iq);

}

void autopilot_ints(known_state_ints& state, known_state_ints& old_state,
					FGNetFDM& buf, FGNetCtrls& bufctrl)
{
	static int j = 0;
	j++;

	/// 45 degree angle
	//signed int min_pitch = -FIX1*45;

	/// need sqrt, cos, acos in fixed point

	signed int dt = FIX1/10;

	/// do rate dampening only for now
	
	/// ELEVATOR - PITCH 
	state.iq = old_state.iq + state.q*dt;
	/// TBD saturation limits on iq
	CLAMP(state.iq, (signed int)(M_PI*FIX1*100));

	state.dq = (state.q - old_state.q);
	/// filter to avoid oscillations
	//state.dq = (state.dq*0.1 + old_state.dq*0.9);	
	if (j < 10) state.dq = 0;

	/*
	state.error_pitch = state.tpitch - state.pitch;
	state.ipitch = old_state.ipitch + state.error_pitch*dt;
	float max_ip = 4.0;
	if (state.ipitch >  max_ip) state.ipitch =  max_ip;
	if (state.ipitch < -max_ip) state.ipitch = -max_ip;
	state.dpitch = (state.error_pitch - old_state.error_pitch)/dt;
	state.dpitch = (state.dpitch*0.1 + old_state.dpitch*0.9);	
	if (j < 10) state.dpitch = 0;
	
	float valp = -(0.15*state.error_pitch + 0.1*state.dpitch + 0.35*state.ipitch);

	float val = (0.2*valq + 0.8*valp);
	*/

	signed int valq  = 14*state.q/100;
	signed int valdq = 10*state.dq/100;
	signed int valiq = 1*state.iq/200000;
	//0.15*state.q; //+ 0.1*state.dq + 0.35*state.iq;
	signed int val = valq + valdq + valiq + 15*FIX1/100;  /// try biasing
	CLAMP(val,FIX1);

	state.elevator = val;

	/// rate limit
	signed int limit_rate = FIX1/30;
	if (state.elevator > (old_state.elevator + limit_rate)) state.elevator = old_state.elevator+limit_rate;
	if (state.elevator < (old_state.elevator - limit_rate)) state.elevator = old_state.elevator-limit_rate;
	
	bufctrl.elevator = fixed_to_float(state.elevator);

	std::cout << val << " " << valq << " " << valdq << " " << valiq << std::endl;
	////////////////////////////////////////////
	/// RUDDER - HEADING

	#if 0
    val = 1.8*state.error_heading + 14.3*state.derror_heading + 0.000001*state.ierror_heading;
	float fadeval = 0.20;
    if (fabs(state.error_heading) < fadeval) val*= fabs(state.error_heading)/fadeval;
	/// ramp down rudder even faster within a few degrees of the target
	/// the thing we want to avoid is flying directly over the target, we want to come at it from few degrees to the side
    if (fabs(state.error_heading) < fadeval/4.0) val*= fabs(state.error_heading)/(fadeval/4.0);
	if (val > 1.0) val = 1.0;
	if (val <-1.0) val =-1.0;


	/// limit rudder based on pitch, the rudder doesn't work too well at high pitches anyway
	float abs_min_pitch = -0.5; /// probably need to ensure this is true;
	if (state.pitch < min_pitch) {
		/// the ratio should vary from 1.0 to 0.0
		float slope = 1.0/(abs_min_pitch - min_pitch);
		float ratio = 1.0 - (state.pitch-min_pitch)*slope;
		val = val * ratio;
	}
	
	/// change the ailerons independently of the rudders when low to the ground
	float aileron_heading_val = val;
	
	/// limit rudder based on distance to target
	/*float approach_dist = 1500;
	if (state.tdist < approach_dist) {
		val = val*(0.3+0.7*state.tdist/approach_dist);
	}*/

	// this assumes a high quality heigh map is flying, I should simulate a lower quality than
	// this 'perfect' value
	float agl_limit = 150;
	if (buf.agl < agl_limit)  val *= (buf.agl/agl_limit);

	bufctrl.rudder = val;
	
	agl_limit = 90;
	if (buf.agl < agl_limit)  aileron_heading_val *= (buf.agl/agl_limit);

#endif 
	val = 40*state.p/100;
	CLAMP(val,FIX1);
	bufctrl.rudder = fixed_to_float(val);

	///////////////////////////////////////////////////////////////////
	/// AILERON - ROLL

#if 0
	/// TBD saturation limits on iq
	state.ir = old_state.ir + state.r*dt;
	/// filter to avoid oscillations
	state.dr = (state.dr*0.1 + old_state.dr*0.9);	
	if (j < 10) state.dr = 0;

	float valr = 0.2*state.r + 0.05*state.dr + 0.0*state.ir;
	
	if (state.r < 0.1) valr*= 0.1;
	
	/// use some of the heading command on the ailerons 
	valr += aileron_heading_val*0.01;
#endif
	state.dr = (state.r - old_state.r)/dt;

	signed int valr = /*5*state.q/100 +*/ -60*state.r/100 + 5*state.dr/100;
	CLAMP(valr,FIX1);
	bufctrl.aileron = fixed_to_float(valr);

}

void autopilot(known_state& state, known_state& old_state,
			   FGNetFDM& buf, FGNetCtrls& bufctrl)
{

	static int j = 0;
	j++;
	
	float dt =1.0/10.0;

	static float hspeed;
	float dt_gps = 1.0;

	/// 45 degree angle
	float min_pitch = -0.25;

	

	////////////////////////////////////////////////////////////////////////
	/// GPS section, only update at 1 Hz
	if (j%int(dt_gps/dt+0.5) == 0) {
		
		///////////////////////////////////////////////////////////////////
		/// find the angle from horizontal
		{
			/// alternate way of getting velocity- this one matches the sim 
			double x1 = (EARTH_RADIUS_METERS+state.altitude)*cos(state.latitude)*cos(state.longitude);
			double y1 = (EARTH_RADIUS_METERS+state.altitude)*cos(state.latitude)*sin(state.longitude);
			double z1 = (EARTH_RADIUS_METERS+state.altitude)*sin(state.latitude);

			double x2 = (EARTH_RADIUS_METERS+old_state.altitude)*cos(old_state.latitude)*cos(old_state.longitude);
			double y2 = (EARTH_RADIUS_METERS+old_state.altitude)*cos(old_state.latitude)*sin(old_state.longitude);
			double z2 = (EARTH_RADIUS_METERS+old_state.altitude)*sin(old_state.latitude);

			// delta xyz to target
			double xt = (EARTH_RADIUS_METERS+target_altitude)*cos(target_latitude)*cos(target_longitude);
			double yt = (EARTH_RADIUS_METERS+target_altitude)*cos(target_latitude)*sin(target_longitude);
			double zt = (EARTH_RADIUS_METERS+target_altitude)*sin(target_latitude);

			double dx = (x1-x2);
			double dy = (y1-y2);
			double dz = (z1-z2);

			// length of vector pointing from old location to current
			float l1 = sqrtf(dx*dx + dy*dy + dz*dz);

			/// length of vector point straight at center of earth
			double l2 = sqrtf(x2*x2 + y2*y2 + z2*z2);
			
	
			double dotprod = ( 
								(dx/l1 * (-x2)/l2) +
								(dy/l1 * (-y2)/l2) +
								(dz/l1 * (-z2)/l2)  );
			
			state.pitch = acos(dotprod)/M_PI -0.5;

			state.tdist = sqrtf(
				(xt-x2)*(xt-x2) + 
				(yt-y2)*(yt-y2) + 
				(zt-z2)*(zt-z2)  );

				
			double dotprodt =  
							(	((xt-x2)/state.tdist * (-x2)/l2) +
								((yt-y2)/state.tdist * (-y2)/l2) +
								((zt-z2)/state.tdist * (-z2)/l2)  );
			state.tpitch = acos(dotprodt)/M_PI -0.5;
			/// add a little something, probably should be proportional to error heading so that we don't lose too much
			/// altitude when we're not pointing towards the target and low in altitude
			if (state.altitude < 1000) state.tpitch += 0.2*fabs(state.error_heading);
			state.speed = l1/dt;
		
			/// find the heading from the dot product of the vertical axis of the earth, due east is zero
			/// turns out that dz is the only contributor, everything else is zeroed out

			/// derive heading from last two lat,long points
			float dlat  = state.latitude  - old_state.latitude;
			WRAP(dlat, M_PI);
			float dlong = 0.0 - (state.longitude - old_state.longitude);
			WRAP(dlong, M_PI);

			float tdlat  = target_latitude  - old_state.latitude;
			WRAP(tdlat, M_PI);
			float tdlong = 0.0 - (target_longitude - old_state.longitude);
			WRAP(tdlong, M_PI);
			
			/// the other dx,dy,dz where in a frame where the axis of the earth points up
			float edx  = 0.0 - dlong*(EARTH_RADIUS_METERS+state.altitude)*cos(state.latitude);
			float edy  = dlat*(EARTH_RADIUS_METERS+state.altitude);

			state.tdx = 0.0 - (tdlong)*EARTH_RADIUS_METERS*cos(state.latitude);
			state.tdy = 	 (tdlat)*EARTH_RADIUS_METERS;

	
			float heading  = atan2(edy,edx)/M_PI;
			float theading = atan2(state.tdy,state.tdx)/M_PI;
		
			/// vector that points in the direction we need to move
			state.error_heading = theading- heading;
			WRAP(state.error_heading, 1.0);

			state.error_heading = -state.error_heading;

			state.derror_heading = (state.error_heading- old_state.error_heading)/dt_gps;
			state.derror_heading = 0.1*state.derror_heading + 0.9*old_state.derror_heading;

			if (j < 10) state.derror_heading = 0;

			state.ierror_heading = old_state.ierror_heading + state.error_heading*dt_gps;
			if (state.ierror_heading >  10.0) state.ierror_heading =  10.0;
			if (state.ierror_heading < -10.0) state.ierror_heading = -10.0;
		}
		
		/// don't try to climb or dive too steep
		/// try to limit velocity with target pitch?
		float max_pitch = -0.005;
		if (state.tpitch > max_pitch) state.tpitch = max_pitch;
		float max_speed = 70.0;
		if (state.speed > max_speed) {
			/// assume no greater speed than 300 m/s
			min_pitch = max_pitch + (min_pitch - max_pitch) * (1.0 - (state.speed-max_speed)/300.0);
		}
		
		/// limit velocity based on distance to target?
		float approach_dist = 3000;
		if (state.tdist < approach_dist) {
			min_pitch = max_pitch + (min_pitch - max_pitch)*state.tdist/approach_dist;
		}

		if (state.tpitch < min_pitch) state.tpitch = min_pitch;
		
		if (j < 10) state.tpitch = 0;

	}
	//// end GPS section
	//////////////////////////////////////////////////////////////////////



		/// ELEVATOR - PITCH 
		state.iq = old_state.iq + state.q*dt;
		/// TBD saturation limits on iq
		state.dq = (state.q - old_state.q)/dt;
		/// filter to avoid oscillations
		state.dq = (state.dq*0.1 + old_state.dq*0.9);	
		if (j < 10) state.dq = 0;

		float valq = 0.15*state.q + 0.1*state.dq + 0.35*state.iq;

		state.error_pitch = state.tpitch - state.pitch;
		state.ipitch = old_state.ipitch + state.error_pitch*dt;
		float max_ip = 4.0;
		if (state.ipitch >  max_ip) state.ipitch =  max_ip;
		if (state.ipitch < -max_ip) state.ipitch = -max_ip;
		state.dpitch = (state.error_pitch - old_state.error_pitch)/dt;
		state.dpitch = (state.dpitch*0.1 + old_state.dpitch*0.9);	
		if (j < 10) state.dpitch = 0;

		float valp = -(0.15*state.error_pitch + 0.1*state.dpitch + 0.35*state.ipitch);

		float val = (0.2*valq + 0.8*valp);
		if (val > 1.0) val = 1.0;
		if (val <-1.0) val =-1.0;
		bufctrl.elevator = val;

		////////////////////////////////////////////
		/// RUDDER - HEADING

		val = 1.8*state.error_heading + 14.3*state.derror_heading + 0.000001*state.ierror_heading;
		float fadeval = 0.20;
		if (fabs(state.error_heading) < fadeval) val*= fabs(state.error_heading)/fadeval;
		/// ramp down rudder even faster within a few degrees of the target
		/// the thing we want to avoid is flying directly over the target, we want to come at it from few degrees to the side
		if (fabs(state.error_heading) < fadeval/4.0) val*= fabs(state.error_heading)/(fadeval/4.0);
		if (val > 1.0) val = 1.0;
		if (val <-1.0) val =-1.0;


		/// limit rudder based on pitch, the rudder doesn't work too well at high pitches anyway
		float abs_min_pitch = -0.5; /// probably need to ensure this is true;
		if (state.pitch < min_pitch) {
			/// the ratio should vary from 1.0 to 0.0
			float slope = 1.0/(abs_min_pitch - min_pitch);
			float ratio = 1.0 - (state.pitch-min_pitch)*slope;
			val = val * ratio;
		}

		/// change the ailerons independently of the rudders when low to the ground
		float aileron_heading_val = val;

		/// limit rudder based on distance to target
		/*float approach_dist = 1500;
		  if (state.tdist < approach_dist) {
		  val = val*(0.3+0.7*state.tdist/approach_dist);
		  }*/

		// this assumes a high quality heigh map is flying, I should simulate a lower quality than
		// this 'perfect' value
		float agl_limit = 150;
		if (buf.agl < agl_limit)  val *= (buf.agl/agl_limit);

		bufctrl.rudder = val;

		agl_limit = 90;
		if (buf.agl < agl_limit)  aileron_heading_val *= (buf.agl/agl_limit);


		///////////////////////////////////////////////////////////////////
		/// AILERON - ROLL

		/// TBD saturation limits on iq
		state.ir = old_state.ir + state.r*dt;
		state.dr = (state.r - old_state.r)/dt;
		/// filter to avoid oscillations
		state.dr = (state.dr*0.1 + old_state.dr*0.9);	
		if (j < 10) state.dr = 0;

		float valr = 0.2*state.r + 0.05*state.dr + 0.0*state.ir;

		if (state.r < 0.1) valr*= 0.1;

		/// use some of the heading command on the ailerons 
		valr += aileron_heading_val*0.01;

		if (valr > 1.0) valr = 1.0;
		if (valr <-1.0) valr =-1.0;
		bufctrl.aileron = valr;

	////////////////////////////////////////////////////////////////////////

}



static void htond (double &x)   
{
		int    *Double_Overlay;
		int     Holding_Buffer;

		Double_Overlay = (int *) &x;
		Holding_Buffer = Double_Overlay [0];

		Double_Overlay [0] = htonl (Double_Overlay [1]);
		Double_Overlay [1] = htonl (Holding_Buffer);
}


static void htonf (float &x)
{
//	if ( sgIsLittleEndian() ) {
		int    *Float_Overlay;
		int     Holding_Buffer;

		Float_Overlay = (int *) &x;
		Holding_Buffer = Float_Overlay [0];

		Float_Overlay [0] = htonl (Holding_Buffer);
//	} else {
//		return;
//	}
}

void FGProps2NetCtrls( FGNetCtrls *net)
{
	int i = 0;

	// convert to network byte order
	net->version = htonl(net->version);
	htond(net->aileron);
	htond(net->elevator);
	htond(net->rudder);
	htond(net->aileron_trim);
	htond(net->elevator_trim);
	htond(net->rudder_trim);
	htond(net->flaps);
	net->flaps_power = htonl(net->flaps_power);
	net->flap_motor_ok = htonl(net->flap_motor_ok);

	net->num_engines = htonl(net->num_engines);
	for ( i = 0; i < FGNetCtrls::FG_MAX_ENGINES; ++i ) {
		net->master_bat[i] = htonl(net->master_bat[i]);
		net->master_alt[i] = htonl(net->master_alt[i]);
		net->magnetos[i] = htonl(net->magnetos[i]);
		net->starter_power[i] = htonl(net->starter_power[i]);
		htond(net->throttle[i]);
		htond(net->mixture[i]);
		net->fuel_pump_power[i] = htonl(net->fuel_pump_power[i]);
		htond(net->prop_advance[i]);
		htond(net->condition[i]);
		net->engine_ok[i] = htonl(net->engine_ok[i]);
		net->mag_left_ok[i] = htonl(net->mag_left_ok[i]);
		net->mag_right_ok[i] = htonl(net->mag_right_ok[i]);
		net->spark_plugs_ok[i] = htonl(net->spark_plugs_ok[i]);
		net->oil_press_status[i] = htonl(net->oil_press_status[i]);
		net->fuel_pump_ok[i] = htonl(net->fuel_pump_ok[i]);
	}

	net->num_tanks = htonl(net->num_tanks);
	for ( i = 0; i < FGNetCtrls::FG_MAX_TANKS; ++i ) {
		net->fuel_selector[i] = htonl(net->fuel_selector[i]);
	}

	net->cross_feed = htonl(net->cross_feed);
	htond(net->brake_left);
	htond(net->brake_right);
	htond(net->copilot_brake_left);
	htond(net->copilot_brake_right);
	htond(net->brake_parking);
	net->gear_handle = htonl(net->gear_handle);
	net->master_avionics = htonl(net->master_avionics);
	htond(net->wind_speed_kt);
	htond(net->wind_dir_deg);
	htond(net->turbulence_norm);
	htond(net->temp_c);
	htond(net->press_inhg);
	htond(net->hground);
	htond(net->magvar);
	net->icing = htonl(net->icing);
	net->speedup = htonl(net->speedup);
	net->freeze = htonl(net->freeze);
}

void FGNetFDM2Props( FGNetFDM *net ) {
    unsigned int i;

    //if ( net_byte_order ) {
        // Convert to the net buffer from network format
        net->version = ntohl(net->version);

        htond(net->longitude);  // use
        htond(net->latitude);   // use 
        htond(net->altitude);   // use
        htonf(net->agl);
        htonf(net->phi);
        htonf(net->theta);
        htonf(net->psi);
        htonf(net->alpha);
        htonf(net->beta);

		///  custom- put ifdef around?
        htonf(net->p);		// use
        htonf(net->q);	// use
        htonf(net->r); 	// use


        htonf(net->phidot);		// use
        htonf(net->thetadot);	// use
        htonf(net->psidot); 	// use
        htonf(net->vcas);
        htonf(net->climb_rate);
        htonf(net->v_north);
        htonf(net->v_east);
        htonf(net->v_down);
        htonf(net->v_wind_body_north);
        htonf(net->v_wind_body_east);
        htonf(net->v_wind_body_down);

        htonf(net->A_X_pilot);	// use
        htonf(net->A_Y_pilot);  // use
        htonf(net->A_Z_pilot);	// use

        htonf(net->stall_warning);
        htonf(net->slip_deg);

}


int main(void)
{
	int sock, sock2;
	struct sockaddr_in echoclient,from, ctrlclient, ctrlinclient;
	unsigned int echolen, clientlen;
	int received = 0;

	FGNetFDM buf;
	char* buffer = (char*)&buf;

	FGNetCtrls bufctrl;
	char* buffer_ctrl = (char*)&bufctrl; 

	struct known_state state; 
	struct known_state old_state; 

	struct known_state_ints state_ints; 
	struct known_state_ints old_state_ints; 
	
	srand ( time(NULL) );
	memset(&state,		0, sizeof(state));
	memset(&old_state,	0, sizeof(state));

	memset(&state_ints,		0, sizeof(state_ints));
	memset(&old_state_ints,	0, sizeof(state_ints));


	/* Create the UDP socket */
	if ((sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
		std::cerr << "Failed to create socket" << std::endl;
		perror("socket");
		return -1;
	}

	if ((sock2 = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
		std::cerr << "Failed to create socket" << std::endl;
		perror("socket");
		return -1;
	}

	/// the port where net fdm is received
	memset(&echoclient, 0, sizeof(echoclient));       /* Clear struct */
	echoclient.sin_family = AF_INET;                  /* Internet/IP */
	echoclient.sin_addr.s_addr = inet_addr("127.0.0.1");  /* IP address */
	echoclient.sin_port = htons(5500);       /* server port */

	/// the port where the modified net ctrl is sent to flightgear
	memset(&ctrlclient, 0, sizeof(ctrlclient));       /* Clear struct */
	ctrlclient.sin_family = AF_INET;                  /* Internet/IP */
	ctrlclient.sin_addr.s_addr = inet_addr("127.0.0.1");  /* IP address */
	ctrlclient.sin_port = htons(5600);       /* server port */

	/// this is the port where the net ctrl comes from flight gear
	memset(&ctrlinclient, 0, sizeof(ctrlinclient));       /* Clear struct */
	ctrlinclient.sin_family = AF_INET;                  /* Internet/IP */
	ctrlinclient.sin_addr.s_addr = inet_addr("127.0.0.1");  /* IP address */
	ctrlinclient.sin_port = htons(5700);       /* server port */

	int length = sizeof(buf);

	std::cout << "packet length should be " << length << " bytes" << std::endl;

	echolen = length;

	char errorbuf[100];

	/// need this?
	int ret  = bind(sock,  (struct sockaddr*)&echoclient, sizeof(echoclient) );
	int ret2 = bind(sock2, (struct sockaddr*)&ctrlinclient, sizeof(ctrlinclient) );
	
	std::cout << "bind " << ret << " " << ret2 << std::endl;
	///////////////////////////////////////////////////////////////////

	std::string file = "telemetry.csv";
	std::ofstream telem(file.c_str(), std::ios_base::out );
	if (!telem) {
		std::cout << "File \"" << file << "\" not found.\n";
		throw fileNotFound();
		return 2;
	}
	telem.precision(10);

    telem <<
	        "longitude, latitude, altitude" <<
			        "p, q, r," <<
					"elevator, rudder, aileron" <<
							            std::endl;


	double time = 0.0; 

	float dist = 40e3; //state.altitude;
	float div = 3e6;
	target_longitude = start_longitude + (float)(rand()%(int)dist)/div - dist/div*0.5; 
	target_latitude  = start_latitude  + (float)(rand()%(int)dist)/div - dist/div*0.5; 
	std::cout << "t longitude=" << target_longitude << ", t latitude=" << target_latitude << std::endl;


	int i = 0;
	while(1) {
	 
	 	i++;
		// I think this clobbers echoclient
		/// receive net_fdm over udp
		received = recvfrom(sock, buffer, sizeof(buf), 0,
						(struct sockaddr *) &from,
						&echolen);
	
/// -extract accelerations A_X_pilot etc, add noise
/// - are phidot, thetadot, psidot in body frame? Probably 
/// (I thought someone told me there was no difference, but that doesn't 
/// make sense- what if the vehicle was 90 degrees up from normal, how is
/// roll still roll?)
/// - take position lat long alt, but filter so it is only updated at a few Hz

/// and that's all we'll know

		FGNetFDM2Props( &buf);

		state.longitude = buf.longitude;
		state.latitude = buf.latitude;
		state.altitude = buf.altitude;

		state.p = buf.p;
		state.q = buf.q;
		state.r = buf.r;

		state.A_X_pilot = buf.A_X_pilot;
		state.A_Y_pilot = buf.A_Y_pilot;
		state.A_Z_pilot = buf.A_Z_pilot;

		/// fixed point version
		
		state_ints.longitude = float_to_fixed(buf.longitude);
		state_ints.latitude  = float_to_fixed(buf.latitude);
		state_ints.altitude  = float_to_fixed(buf.altitude);

		state_ints.p = float_to_fixed(buf.p);
		state_ints.q = float_to_fixed(buf.q);
		state_ints.r = float_to_fixed(buf.r);

		state_ints.A_X_pilot = float_to_fixed(buf.A_X_pilot);
		state_ints.A_Y_pilot = float_to_fixed(buf.A_Y_pilot);
		state_ints.A_Z_pilot = float_to_fixed(buf.A_Z_pilot);


		if (received < 0) {
			perror("recvfrom");
	//	} else if (received != echolen) {
	//		std::cerr << "wrong sized packet " << received << std::endl;
		} else {

			/// get the ctrls that are properly filled out with environmental
			/// data, so we don't clobber that when we modify the flap positions
			received = recvfrom(sock2, buffer_ctrl, sizeof(bufctrl), 0,
						(struct sockaddr *) &ctrlinclient,
						&echolen);

			FGProps2NetCtrls(&bufctrl);

			//autopilot(state, old_state, buf, bufctrl);
			autopilot_ints(state_ints, old_state_ints, buf, bufctrl);

			state_fixed_to_float(state_ints,state);

			/// output to file and stdout 
			{
				/// save telemetry to file
				telem << 
					state.longitude << "," << state.latitude << "," << state.altitude*M2FT << "," <<
					state.p << "," << state.q << "," << state.r << "," <<
					bufctrl.elevator << "," << bufctrl.rudder << "," << bufctrl.aileron << "," <<
					state.dq << "," << state.iq << "," << 
					state.error_heading << "," << state.derror_heading << "," << state.ierror_heading << "," << 
					state.error_pitch << "," << state.dpitch << "," << state.ipitch << "," <<
					state.tpitch << "," << state.speed*M2FT << "," << 
					state.tdx*M2FT << "," << state.tdy*M2FT << "," << 
					bufctrl.wind_speed_kt << "," << bufctrl.wind_dir_deg << "," << bufctrl.press_inhg << "," <<  
					state.dr << "," << state.ir << "," << state.pitch << 
					state.A_X_pilot*M2FT << "," << state.A_Y_pilot*M2FT << "," << state.A_Z_pilot*M2FT << "," << 
					std::endl;


				/// output some of the state to stdout every few seconds
				static int i = 0;
				i++;
				if (i % 30 == 0) {
					std::cout <<
						", hor dist=" << M2FT*sqrtf(state.tdist*state.tdist - (state.altitude-target_altitude)*(state.altitude-target_altitude)) <<
						", agl=" << buf.agl*M2FT << ", alt=" << state.altitude*M2FT << ", vel=" << state.speed*M2FT << 
						//		", fdm v= " << sqrtf(buf.v_north*buf.v_north + buf.v_east*buf.v_east + buf.v_down*buf.v_down)*0.3048 <<
						//	" tdx=" << state.tdx*M2FT << ", tdy=" << state.tdy*M2FT <<
						//		" heading= " << heading << " target heading= " << theading <<
						", err_head= " << state.error_heading << ", rud=" << bufctrl.rudder <<
						//			", lat= " << state.latitude << ", long= " << state.longitude << ", alt= " << state.altitude <<
						", pitch= " << state.pitch << ", tpitch= " << state.tpitch << ", elev=" << bufctrl.elevator <<
						//	", p=" << state.p <<  
						//		", q=" << state.q << ", elev=" << bufctrl.elevator <<
						//	", r=" << state.r << ", ail= " << bufctrl.aileron << 
						std::endl;
				}
			}


			//std::cout << old_state.altitude << " " << state.altitude << std::endl;
			memcpy(&old_state, &state, sizeof(state));
			
			
			memcpy(&old_state_ints, &state_ints, sizeof(state_ints));


			////////////////////////////////////////////////////////////////////////

			received = sendto(sock, buffer_ctrl, sizeof(bufctrl), 0,
			(struct sockaddr *) &ctrlclient, sizeof(ctrlclient));

			
			if (received <0) {
				perror("sendto");
			}

			time += 0.1;	
		
		}

		usleep(1000);
	}
return 0;
}
