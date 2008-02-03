/*
 * GNU GPL
 *
 * 2008 binarymillenium
 *
 *
 */

#include "net_fdm.hxx"

#include <stdio.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <netinet/in.h>
#include <errno.h>

//#define BUFFSIZE 408

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


void FGNetFDM2Props( FGNetFDM *net ) {
    unsigned int i;

    //if ( net_byte_order ) {
        // Convert to the net buffer from network format
        net->version = ntohl(net->version);

        htond(net->longitude);
        htond(net->latitude);
        htond(net->altitude);
        htonf(net->agl);
        htonf(net->phi);
        htonf(net->theta);
        htonf(net->psi);
        htonf(net->alpha);
        htonf(net->beta);

        htonf(net->phidot);
        htonf(net->thetadot);
        htonf(net->psidot);
        htonf(net->vcas);
        htonf(net->climb_rate);
        htonf(net->v_north);
        htonf(net->v_east);
        htonf(net->v_down);
        htonf(net->v_wind_body_north);
        htonf(net->v_wind_body_east);
        htonf(net->v_wind_body_down);

        htonf(net->A_X_pilot);
        htonf(net->A_Y_pilot);
        htonf(net->A_Z_pilot);

        htonf(net->stall_warning);
        htonf(net->slip_deg);

}


int main(void)
{
	int sock;
	struct sockaddr_in echoclient,from;
	//char buffer[BUFFSIZE];
	unsigned int echolen, clientlen;
	int received = 0;

	FGNetFDM buf;
	char* buffer = (char*)&buf;

	/* Create the UDP socket */
	if ((sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
		std::cerr << "Failed to create socket" << std::endl;
		perror("socket");
		return -1;
	}

	/* Construct the server sockaddr_in structure */
	memset(&echoclient, 0, sizeof(echoclient));       /* Clear struct */
	echoclient.sin_family = AF_INET;                  /* Internet/IP */
	//echoclient.sin_addr.s_addr = inet_addr("127.0.0.1");  /* IP address */
	echoclient.sin_addr.s_addr = (inet_addr("192.168.1.101"));  /* IP address */
	echoclient.sin_port = htons(5500);       /* server port */

/// receive net_fdm over udp
///
//
	int length = sizeof(buf);

	std::cout << "packet length should be " << length << " bytes" << std::endl;

	echolen = length;

	char errorbuf[100];

	/// need this?
	int ret = bind(sock, (struct sockaddr*)&echoclient, sizeof(echoclient) );
	
	std::cout << "bind " << ret << std::endl;


	while(1) {
/*
		received = sendto(sock, buffer, BUFFSIZE, 0,
			(struct sockaddr *) &echoclient, sizeof(echoclient));

			std::cout << "sent " << received << " bytes " << errno <<std::endl;
	
		perror("sendto");
		usleep(1000000);
*/
		// I think this clobbers echoclient
		received = recvfrom(sock, buffer, sizeof(buf), 0,
						(struct sockaddr *) &from,
						&echolen);
			
		if (received < 0) {
			perror("recvfrom");
	//	} else if (received != echolen) {
	//		std::cerr << "wrong sized packet " << received << std::endl;
		} else {

			/// copy buffer into fdm struct

			FGNetFDM2Props( &buf);
			std::cout << "altitude " << buf.altitude << " bytes " << std::endl;
		}
		usleep(1000);

	}
	
/// -extract accelerations A_X_pilot etc, add noise
/// - are phidot, thetadot, psidot in body frame? Probably 
/// (I thought someone told me there was no difference, but that doesn't 
/// make sense- what if the vehicle was 90 degrees up from normal, how is
/// roll still roll?)
/// - take position lat long alt, but filter so it is only updated at a few Hz

/// and that's all we'll know

return 0;
}
