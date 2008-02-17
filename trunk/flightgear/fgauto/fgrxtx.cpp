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

#define M_PI 3.14592
#include <cmath>

#include <iostream>
#include <fstream>

typedef signed int       int32_t;
typedef unsigned int     uint32_t;

#include "net_fdm.hxx"
#include "net_ctrls.hxx"

#define WRAP(x,t) {if ((x) > (t)) (x) = 2*(t)-(x); if ((x) < -(t)) (x) = 2.0+(x);}


//start pos is 0.656384, long= -2.1355,
const double target_longitude = -2.137; 
const double target_latitude  = .658;
const double target_altitude  = 60; //meters 

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
	//float tlenxy;  // horizontal distance to target

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
};

class fileNotFound {};

void autopilot(known_state& state, known_state& old_state,
FGNetFDM& buf, FGNetCtrls& bufctrl,
std::ofstream& telem) 
{

	static int j = 0;
	j++;
	
	float dt =1.0/10.0;
	//std::cout << "altitude " << buf.altitude << " bytes " << std::endl;

	static float hspeed;
	float dt_gps = 1.0;
	////////////////////////////////////////////////////////////////////////
	/// GPS section, only update at 1 Hz
	if (j%int(dt_gps/dt+0.5) == 0) {
		

		//////////////////////////////////////////////////////////////
		
		///////////////////////////////////////////////////////////////////
		/// find the angle from horizontal
		{
			/// alternate way of getting velocity- this one matches the sim 
			double x1 = (EARTH_RADIUS_METERS+state.altitude)*cos(state.latitude)*cos(state.longitude);
			double y1 = (EARTH_RADIUS_METERS+state.altitude)*cos(state.latitude)*sin(state.longitude);
			double z1 = (EARTH_RADIUS_METERS+state.altitude)*sin(state.latitude);

//			double l1 = sqrtf(x1*x1 + y1*y1 + z1*z1);

			double x2 = (EARTH_RADIUS_METERS+old_state.altitude)*cos(old_state.latitude)*cos(old_state.longitude);
			double y2 = (EARTH_RADIUS_METERS+old_state.altitude)*cos(old_state.latitude)*sin(old_state.longitude);
			double z2 = (EARTH_RADIUS_METERS+old_state.altitude)*sin(old_state.latitude);


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
			state.speed = l1/dt;
		
			//std::cout << buf.agl << " " <<  dotprodt << " " << state.tpitch <<  std::endl;	
			
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

			state.tdy = 	 (tdlat)*EARTH_RADIUS_METERS;
			state.tdx = 0.0-(tdlong)*EARTH_RADIUS_METERS*cos(state.latitude);

			//float tlen = sqrtf(tdlat*tdlat + tdlong*tdlong);
	
			//float heading  = atan2(dy,dx)/M_PI;
			float heading  = atan2(dlat,dlong)/M_PI;
			//float theading = atan2(state.tdy,state.tdx)/M_PI;
			float theading = atan2(tdlat,tdlong)/M_PI;
		

			//double theading = 0;
			//double heading_dz = acos( dz/l1) )/M_PI + 0.5;

			//std::cout << heading << ", heading_dz=" << heading_dz << std::endl;

			/// vector that points in the direction we need to move
			state.error_heading = theading- heading;
			WRAP(state.error_heading, 1.0);

			state.derror_heading = (state.error_heading- old_state.error_heading)/dt_gps;
			state.derror_heading = 0.1*state.derror_heading + 0.9*old_state.derror_heading;

			if (j < 10) state.derror_heading = 0;

			state.ierror_heading = old_state.ierror_heading + state.error_heading*dt_gps;
			if (state.ierror_heading >  10.0) state.ierror_heading =  10.0;
			if (state.ierror_heading < -10.0) state.ierror_heading = -10.0;
		}

		/*
		float dx = dlong*2.0*(EARTH_RADIUS_METERS+state.altitude)*cos(state.latitude);
		float dy = dlat*(EARTH_RADIUS_METERS+state.altitude);
		float dlenxy = sqrtf(dx*dx + dy*dy);
		//float dlen = sqrtf(dlat*dlat + dlong*dlong);
		float dalt = state.altitude - old_state.altitude;

		state.pitch = atan2(dalt, dlenxy)/M_PI; /// convert to -1 to 1
		state.speed = sqrtf(dlenxy*dlenxy + dalt*dalt)/dt_gps;	
		if (j < 10) state.speed = 0;
		
		hspeed = dlenxy/dt_gps;	

		/// find the necessary pitch to descend to the target

		state.tlenxy = sqrtf(state.tdx*state.tdx + state.tdy*state.tdy);
		*/
				/// don't try to climb or dive too steep
		/// try to limit velocity with target pitch?
		float max_pitch = -0.05;
		if (state.tpitch > max_pitch) state.tpitch = max_pitch;
		float min_pitch = -0.34;

		float max_speed = 100.0;
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
	state.dpitch = (state.dpitch*0.02 + old_state.dpitch*0.98);	
	if (j < 10) state.dpitch = 0;
	
	float valp = -(0.15*state.error_pitch + 0.1*state.dpitch + 0.35*state.ipitch);

	float val = (0.2*valq + 0.8*valp);
	if (val > 1.0) val = 1.0;
	if (val <-1.0) val =-1.0;
	bufctrl.elevator = val;
	
    val = 0.7*state.error_heading + 14.3*state.derror_heading + 0.000001*state.ierror_heading;
	float fadeval = 0.1;
    if (fabs(state.error_heading) < fadeval) val*=fabs(state.error_heading)/fadeval;
	if (val > 1.0) val = 1.0;
	if (val <-1.0) val =-1.0;
	/// limit heading commands above certain height
	float min_height = 10000;
	if (state.altitude > min_height) {
		val = val * (1.0 - (state.altitude-min_height)/(30e3-min_height));
	}
	/// limit rudder based on distance to target
	float approach_dist = 3000;
	if (state.tdist < approach_dist) {
		val = val*state.tdist/approach_dist;
	}
	bufctrl.rudder = val;


	/// TBD saturation limits on iq
	state.ir = old_state.ir + state.r*dt;
	state.dr = (state.r - old_state.r)/dt;
	/// filter to avoid oscillations
	state.dr = (state.dr*0.1 + old_state.dr*0.9);	
	if (j < 10) state.dr = 0;
	
	float valr = 0.2*state.r + 0.05*state.dr + 0.0*state.ir;
	
	if (state.r < 0.1) valr*= 0.1;
	valr += val*0.01;

	if (valr > 1.0) valr = 1.0;
	if (valr <-1.0) valr =-1.0;
	bufctrl.aileron = valr;


	/// save telemetry to file
	telem << 
		state.longitude << "," << state.latitude << "," << state.altitude << "," <<
		state.p << "," << state.q << "," << state.r << "," <<
		bufctrl.elevator << "," << bufctrl.rudder << "," << bufctrl.aileron << "," <<
		state.dq << "," << state.iq << "," << 
		state.error_heading << "," << state.derror_heading << "," << state.ierror_heading << "," << 
		state.error_pitch << "," << state.dpitch << "," << state.ipitch << "," <<
		state.tpitch << "," << state.speed << "," << 
		state.tdx << "," << state.tdy << "," << 
		bufctrl.wind_speed_kt << "," << bufctrl.wind_dir_deg << "," << bufctrl.press_inhg << "," <<  
		state.dr << "," << state.ir << "," << state.pitch << 
		std::endl;


	/// output some of the state to stdout every few seconds
	static int i = 0;
	i++;
	if (i % 30 == 0) {
		std::cout <<
			", hor dist=" << sqrtf(state.tdist*state.tdist - (state.altitude-target_altitude)*(state.altitude-target_altitude)) <<
			", agl=" << buf.agl << ", alt=" << state.altitude << ", vel=" << state.speed << 
	//		", fdm v= " << sqrtf(buf.v_north*buf.v_north + buf.v_east*buf.v_east + buf.v_down*buf.v_down)*0.3048 <<
		//	" tdx=" << state.tdx << ", tdy=" << state.tdy <<
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

	memset(&state,	0, sizeof(state));
	memset(&old_state,	0, sizeof(state));


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

			autopilot(state, old_state, buf, bufctrl, telem);

			//std::cout << old_state.altitude << " " << state.altitude << std::endl;
			memcpy(&old_state, &state, sizeof(state));


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
