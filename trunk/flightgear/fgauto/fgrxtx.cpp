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

// start pos is 0.653036, -2.11387,
double target_longitude = -2.15; 
double target_latitude  = .665; 


struct known_state {
	double longitude;
	double latitude;
	double altitude;

	float error_heading; /// degrees
	float derror_heading;
	float ierror_heading;

	float p;
	float q;
	float r;

	float iq;  // integral of q

	float A_X_pilot;
	float A_Y_pilot;
	float A_Z_pilot;
};

class fileNotFound {};

void autopilot(known_state& state, known_state& old_state, FGNetCtrls& bufctrl,
std::ofstream& telem) 
{

	float dt = 0.1;
	//std::cout << "altitude " << buf.altitude << " bytes " << std::endl;

	/// derive heading from last two lat,long points
	
	/// ignore cos error with angles for now
	float dlat  = state.latitude  - old_state.latitude;
	/// is long in degrees west?
	float dlong = 0.0 - (state.longitude - old_state.longitude);
	float dlen = sqrtf(dlat*dlat + dlong*dlong);

	float heading = atan2(dlat,dlong)* 180/M_PI;

	float tdlat  = target_latitude  - old_state.latitude;
	/// is long in degrees west?
	float tdlong = 0.0 - (target_longitude - old_state.longitude);

	float tlen = sqrtf(tdlat*tdlat + tdlong*tdlong);
	float theading = atan2(tdlat,tdlong)* 180/M_PI;

	/// vector that points in the direction we need to move
	//float dir_lat = tdlat/tlen - dlat/dlen;
	//float dir_long = tdlong/tlen - dlong/dlen;
	//float state.error_heading = atan2(dir_lat, dir_long)*180/M_PI;
	state.error_heading = theading- heading;
	if (state.error_heading >  180.0) state.error_heading = 360.0-state.error_heading;
	if (state.error_heading < -180.0) state.error_heading = 360.0+state.error_heading;

	
	float dalt = state.altitude - old_state.altitude;

	state.derror_heading = (state.error_heading- old_state.error_heading)/dt;
	state.derror_heading = 0.002*state.derror_heading + 0.998*old_state.derror_heading;
	
	static int j = 0;
	if (j < 20) state.derror_heading = 0;
	j++;

	state.ierror_heading = old_state.ierror_heading + state.error_heading*dt;
	if (state.ierror_heading >  1800.0) state.ierror_heading = 1800.0;
	if (state.ierror_heading < -1800.0) state.ierror_heading = -1800.0;



	state.iq = old_state.iq + state.q*dt;
	//std::cout << state.q << " " <<  state.iq << std::endl;

	float dq = (state.q - old_state.q)/dt;	
	float val = 0.15*state.q + 0.01*dq + 0.4*state.iq;
	if (val > 1.0) val = 1.0;
	if (val <-1.0) val =-1.0;
	bufctrl.elevator = val;
	
    val = 0.5*state.error_heading/180.0 + 2.0*state.derror_heading/180.0 + 0.00001*state.ierror_heading;
	if (val > 1.0) val = 1.0;
	if (val <-1.0) val =-1.0;
	bufctrl.rudder = val;
	
	val = 0.95*state.r;
	if (val > 1.0) val = 1.0;
	if (val <-1.0) val =-1.0;
	//bufctrl.aileron = val;

	telem << 
		state.longitude << "," << state.latitude << "," << state.altitude << "," <<
		state.p << "," << state.q << "," << state.r << "," <<
		bufctrl.elevator << "," << bufctrl.rudder << "," << bufctrl.aileron << "," <<
		dq << "," << state.iq << "," << 
		state.error_heading << "," << state.derror_heading << "," << state.ierror_heading << 
			std::endl;

	static int i = 0;
	i++;
	if (i % 30 == 0) {
		std::cout << 
			//" heading= " << heading <<
			//" target heading= " << theading <<
			" err_head= " << state.error_heading << ", rud=" << bufctrl.rudder <<
		//	", lat= " << state.latitude << 
		//	", long= " << state.longitude << 
			", alt= " << state.altitude <<
			", p=" << state.p <<  
			", q=" << state.q << ", elev=" << bufctrl.elevator <<
			", r=" << state.r << ", ail= " << bufctrl.aileron << 
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

			autopilot(state, old_state, bufctrl, telem);

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
