
#include "fgrxtx.hpp" 

float find_orientation(float ax, float ay, float az )
{
	float y_min = 20.0;
	float x_min = 25.0;
	float min = 35.0;
	float gravity = 55.0;

	if ((fabs(ax) < x_min) && (fabs(ay) < y_min)) {
		if (fabs(az+gravity) < min) {	
			return 1.0;
		} else if (fabs(az-gravity) < min) {
			return -0.8;
		} else {
			return 0.7;
		}
	} else {
		return 0.4;
	}


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
			double state_radius = (EARTH_RADIUS_METERS+state.altitude);
			double x1 = state_radius*cos(state.latitude)*cos(state.longitude);
			double y1 = state_radius*cos(state.latitude)*sin(state.longitude);
			double z1 = state_radius*sin(state.latitude);

			double old_state_radius = (EARTH_RADIUS_METERS+old_state.altitude);
			double x2 = old_state_radius*cos(old_state.latitude)*cos(old_state.longitude);
			double y2 = old_state_radius*cos(old_state.latitude)*sin(old_state.longitude);
			double z2 = old_state_radius*sin(old_state.latitude);

			double t_radius = (EARTH_RADIUS_METERS+state.target_alt);
			double xt = t_radius*cos(state.target_lat)*cos(state.target_long);
			double yt = t_radius*cos(state.target_lat)*sin(state.target_long);
			double zt = t_radius*sin(state.target_lat);

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

			// delta xyz to target
			double tdx = xt-x2;
			double tdy = yt-y2;
			double tdz = zt-z2;
			state.tdist = sqrtf( tdx*tdx + tdy*tdy + tdz*tdz  );

				
			double dotprodt =  
							(	(tdx/state.tdist * (-x2)/l2) +
								(tdy/state.tdist * (-y2)/l2) +
								(tdz/state.tdist * (-z2)/l2)  );
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

			float tdlat  = state.target_lat  - old_state.latitude;
			WRAP(tdlat, M_PI);
			float tdlong = 0.0 - (state.target_long - old_state.longitude);
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


	state.acc_orientation = 0.8*old_state.acc_orientation +
						    0.2*find_orientation(state.A_X_pilot,
											     state.A_Y_pilot, state.A_Z_pilot);
	
		
		/// ELEVATOR - PITCH
		// pitch stabilization
		state.iq = old_state.iq + state.q*dt;
		/// TBD saturation limits on iq
		state.dq = (state.q - old_state.q)/dt;
		/// filter to avoid oscillations
		state.dq = (state.dq*0.1 + old_state.dq*0.9);	
		if (j < 10) state.dq = 0;

		float pitch_stab = 0.15*state.q + 0.1*state.dq + 0.35*state.iq;
	
		// pitch targeting
		state.error_pitch = state.tpitch - state.pitch;
		state.ipitch = old_state.ipitch + state.error_pitch*dt;
		float max_ip = 4.0;
		if (state.ipitch >  max_ip) state.ipitch =  max_ip;
		if (state.ipitch < -max_ip) state.ipitch = -max_ip;
		state.dpitch = (state.error_pitch - old_state.error_pitch)/dt;
		state.dpitch = (state.dpitch*0.1 + old_state.dpitch*0.9);	
		if (j < 10) state.dpitch = 0;

		float pitch_targeting = -(0.15*state.error_pitch + 0.1*state.dpitch + 0.35*state.ipitch);
		
		float elev = (0.2*pitch_stab + (float)(state.acc_orientation)*0.8*pitch_targeting);
		elev = bufctrl.elevator*0.8 + elev*0.2;
		if (elev > 1.0) elev = 1.0;
		if (elev <-1.0) elev =-1.0;
		bufctrl.elevator = FPFIX(elev);

		////////////////////////////////////////////
		/// RUDDER - HEADING

		float heading_targeting = 1.8*state.error_heading + 
							     14.3*state.derror_heading + 0.000001*state.ierror_heading;
		float fadeval = 0.20;
		if (fabs(state.error_heading) < fadeval)
			heading_targeting*= fabs(state.error_heading)/fadeval;
		/// ramp down rudder even faster within a few degrees of the target
		/// the thing we want to avoid is flying directly over the target, we want to come at it from few degrees to the side
		if (fabs(state.error_heading) < fadeval/4.0) 
				heading_targeting*= fabs(state.error_heading)/(fadeval/4.0);

		/// limit rudder based on pitch, the rudder doesn't work too well at high pitches anyway
		float abs_min_pitch = -0.5; /// probably need to ensure this is true;
		if (state.pitch < min_pitch) {
			/// the ratio should vary from 1.0 to 0.0
			float slope = 1.0/(abs_min_pitch - min_pitch);
			float ratio = 1.0 - (state.pitch-min_pitch)*slope;
			heading_targeting = heading_targeting * ratio;
		}

		/// change the ailerons independently of the rudders when low to the ground
		float aileron_heading_val = heading_targeting;

		/// limit rudder based on distance to target
		/*float approach_dist = 1500;
		  if (state.tdist < approach_dist) {
		  val = val*(0.3+0.7*state.tdist/approach_dist);
		  }*/

		// this assumes a high quality heigh map is flying, I should simulate a lower quality than
		// this 'perfect' value
		float agl_limit = 150;
		if (buf.agl < agl_limit)  heading_targeting *= (buf.agl/agl_limit);
	
		heading_targeting *= (float)(state.acc_orientation);	
		/// crude filtering
		heading_targeting = bufctrl.rudder*0.9 + 0.1*heading_targeting;

		if (heading_targeting > 1.0) heading_targeting = 1.0;
		if (heading_targeting <-1.0) heading_targeting =-1.0;
		bufctrl.rudder = FPFIX(heading_targeting);


		///////////////////////////////////////////////////////////////////
		/// AILERON - ROLL

		/// TBD saturation limits on iq
		state.ir = old_state.ir + state.r*dt;
		state.dr = (state.r - old_state.r)/dt;
		/// filter to avoid oscillations
		state.dr = (state.dr*0.1 + old_state.dr*0.9);	
		if (j < 10) state.dr = 0;

		float roll_stab = 0.2*state.r + 0.05*state.dr + 0.0*state.ir;

		if (state.r < 0.1) roll_stab*= 0.1;

		/// use some of the heading command on the ailerons 
		roll_stab += (float)(state.acc_orientation)*aileron_heading_val*0.01;


		if (roll_stab > 1.0) roll_stab = 1.0;
		if (roll_stab <-1.0) roll_stab =-1.0;
		bufctrl.aileron = fixed_to_float(float_to_fixed(roll_stab));

	////////////////////////////////////////////////////////////////////////

}

