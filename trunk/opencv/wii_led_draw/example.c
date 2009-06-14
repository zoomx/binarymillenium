/*
 *	draw an image using the wii LED
 *
 *  binarymillenium@gmail.com
 *
 *
 *	This program is free software; you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation; either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *	$Header$
 *	Based on wiiuse example by Michael Laforest
 */

/**
 *	@file
 *
 *	@brief Example using the wiiuse API.
 *
 *	This file is an example of how to use the wiiuse library.
 */

#include <stdio.h>
#include <stdlib.h>

#ifndef WIN32
	#include <unistd.h>
#endif

#include "cv.h"
#include "highgui.h"

#include "wiiuse.h"


#define MAX_WIIMOTES				4


IplImage* img = NULL;

/**
 *	@brief Callback that handles an event.
 *
 *	@param wm		Pointer to a wiimote_t structure.
 *
 *	This function is called automatically by the wiiuse library when an
 *	event occurs on the specified wiimote. power.
 */
void handle_event(struct wiimote_t* wm) {
	printf("\n\n--- EVENT [id %i] ---\n", wm->unid);


	/* if the accelerometer is turned on then print angles */
	if (WIIUSE_USING_ACC(wm)) {
		printf("wiimote roll  = %f [%f]\n", wm->orient.roll, wm->orient.a_roll);
		printf("wiimote pitch = %f [%f]\n", wm->orient.pitch, wm->orient.a_pitch);
		printf("wiimote yaw   = %f\n", wm->orient.yaw);
	}

	/*
	 *	If IR tracking is enabled then print the coordinates
	 *	on the virtual screen that the wiimote is pointing to.
	 *
	 *	Also make sure that we see at least 1 dot.
	 */
	if (WIIUSE_USING_IR(wm)) {
		int i = 0;

		/* go through each of the 4 possible IR sources */
		for (; i < 4; ++i) {
			/* check if the source is visible */
			if (wm->ir.dot[i].visible) {
				printf("IR source %i: (%u, %u)\n", i, wm->ir.dot[i].x, wm->ir.dot[i].y);

				if ((i == 0) && (CV_IMAGE_ELEM(img,uchar,wm->ir.dot[i].x, wm->ir.dot[i].y)  == 255)) {
					wiiuse_set_leds(wm, WIIMOTE_LED_1);
				} else {
					wiiuse_set_leds(wm, 0);
				}

			}
		}

		printf("IR cursor: (%u, %u)\n", wm->ir.x, wm->ir.y);
		printf("IR z distance: %f\n", wm->ir.z);
	}

}


/**
 *	@brief Callback that handles a read event.
 *
 *	@param wm		Pointer to a wiimote_t structure.
 *	@param data		Pointer to the filled data block.
 *	@param len		Length in bytes of the data block.
 *
 *	This function is called automatically by the wiiuse library when
 *	the wiimote has returned the full data requested by a previous
 *	call to wiiuse_read_data().
 *
 *	You can read data on the wiimote, such as Mii data, if
 *	you know the offset address and the length.
 *
 *	The \a data pointer was specified on the call to wiiuse_read_data().
 *	At the time of this function being called, it is not safe to deallocate
 *	this buffer.
 */
void handle_read(struct wiimote_t* wm, byte* data, unsigned short len) {
	int i = 0;

	printf("\n\n--- DATA READ [wiimote id %i] ---\n", wm->unid);
	printf("finished read of size %i\n", len);
	for (; i < len; ++i) {
		if (!(i%16))
			printf("\n");
		printf("%x ", data[i]);
	}
	printf("\n\n");
}


/**
 *	@brief Callback that handles a controller status event.
 *
 *	@param wm				Pointer to a wiimote_t structure.
 *	@param attachment		Is there an attachment? (1 for yes, 0 for no)
 *	@param speaker			Is the speaker enabled? (1 for yes, 0 for no)
 *	@param ir				Is the IR support enabled? (1 for yes, 0 for no)
 *	@param led				What LEDs are lit.
 *	@param battery_level	Battery level, between 0.0 (0%) and 1.0 (100%).
 *
 *	This occurs when either the controller status changed
 *	or the controller status was requested explicitly by
 *	wiiuse_status().
 *
 *	One reason the status can change is if the nunchuk was
 *	inserted or removed from the expansion port.
 */
void handle_ctrl_status(struct wiimote_t* wm) {
	printf("\n\n--- CONTROLLER STATUS [wiimote id %i] ---\n", wm->unid);

	printf("attachment:      %i\n", wm->exp.type);
	printf("speaker:         %i\n", WIIUSE_USING_SPEAKER(wm));
	printf("ir:              %i\n", WIIUSE_USING_IR(wm));
	printf("leds:            %i %i %i %i\n", WIIUSE_IS_LED_SET(wm, 1), WIIUSE_IS_LED_SET(wm, 2), WIIUSE_IS_LED_SET(wm, 3), WIIUSE_IS_LED_SET(wm, 4));
	printf("battery:         %f %%\n", wm->battery_level);
}


/**
 *	@brief Callback that handles a disconnection event.
 *
 *	@param wm				Pointer to a wiimote_t structure.
 *
 *	This can happen if the POWER button is pressed, or
 *	if the connection is interrupted.
 */
void handle_disconnect(wiimote* wm) {
	printf("\n\n--- DISCONNECTED [wiimote id %i] ---\n", wm->unid);
}


void test(struct wiimote_t* wm, byte* data, unsigned short len) {
	printf("test: %i [%x %x %x %x]\n", len, data[0], data[1], data[2], data[3]);
}

// for the wii leds, huemin 80 100 works okay
void getBlueParts(int huemin, int huemax, CvCapture* cap, 
                  IplImage* blue,   IplImage* msk,   IplImage* blue_rgb, 
                  IplImage* output, IplImage* frame, 
                  IplImage* hsv, IplImage* hue, IplImage* var)
{
        if (!cvGrabFrame(cap)) { 
            printf("cvGrabFrame failed");
            return;
        }

        frame = cvRetrieveFrame(cap);

        if (!frame) {
            printf("bad cvRetrieveFrame");
            return;
        }
       
        cvCopy(frame, output);

        /// now find bright blue parts of frame and save them in blue image
        cvCvtColor(frame,hsv, CV_BGR2HSV);
        cvSetImageCOI(hsv,1);
        cvCopy(hsv, hue);
        cvInRangeS(hue, cvScalarAll(huemin), cvScalarAll(huemax), hue);
        
        cvSetImageCOI(hsv,3);
        cvCopy(hsv, var);
        cvInRangeS(var, cvScalarAll(245), cvScalarAll(255), var);
        cvAnd(hue,var, msk);
        //
        
        //cvErode(msk,msk, NULL, 1);
        cvDilate(msk,msk, NULL, 1);
        
        cvAdd(blue, msk,blue);
        cvSetImageCOI(blue_rgb,1);
        cvCopy(blue,blue_rgb);
        
        
        cvSetImageCOI(blue_rgb,0);
        cvAdd(output,blue_rgb, output);

        cvShowImage("wii_led_draw",output);
        cvWaitKey(20);
        }


/**
 *	@brief main()
 *
 *	Connect to up to two wiimotes and print any events
 *	that occur on either device.
 */
int main(int argc, char** argv) {
    int huemin = atoi(argv[1]);
    int huemax = atoi(argv[2]);

    wiimote** wiimotes;
	int found, connected;

    CvCapture* cap = cvCaptureFromCAM(0);

    if (cap == NULL) {
        printf("no camera found");
        return -1;
    }
    
    cvNamedWindow("wii_led_draw",CV_WINDOW_AUTOSIZE);

	/*
	 *	Initialize an array of wiimote objects.
	 *
	 *	The parameter is the number of wiimotes I want to create.
	 */
	wiimotes =  wiiuse_init(MAX_WIIMOTES);

	/*
	 *	Find wiimote devices
	 *
	 *	Now we need to find some wiimotes.
	 *	Give the function the wiimote array we created, and tell it there
	 *	are MAX_WIIMOTES wiimotes we are interested in.
	 *
	 *	Set the timeout to be 5 seconds.
	 *
	 *	This will return the number of actual wiimotes that are in discovery mode.
	 */
	found = wiiuse_find(wiimotes, MAX_WIIMOTES, 1);  // TBD make longer later
	if (!found) {
		printf ("No wiimotes found.");
		//return 0;
	}

	/*
	 *	Connect to the wiimotes
	 *
	 *	Now that we found some wiimotes, connect to them.
	 *	Give the function the wiimote array and the number
	 *	of wiimote devices we found.
	 *
	 *	This will return the number of established connections to the found wiimotes.
	 */
	connected = wiiuse_connect(wiimotes, MAX_WIIMOTES);
	if (connected)
		printf("Connected to %i wiimotes (of %i found).\n", connected, found);
	else {
		printf("Failed to connect to any wiimote.\n");
		//return 0;
	}

	/*
	 *	Now set the LEDs and rumble for a second so it's easy
	 *	to tell which wiimotes are connected (just like the wii does).
	 */
	wiiuse_set_leds(wiimotes[0], WIIMOTE_LED_1);
	wiiuse_set_leds(wiimotes[1], WIIMOTE_LED_2);
	wiiuse_set_leds(wiimotes[2], WIIMOTE_LED_3);
	wiiuse_set_leds(wiimotes[3], WIIMOTE_LED_4);
	wiiuse_rumble(wiimotes[0], 1);
	wiiuse_rumble(wiimotes[1], 1);

	#ifndef WIN32
		usleep(200000);
	#else
		Sleep(200);
	#endif

	wiiuse_rumble(wiimotes[0], 0);
	wiiuse_rumble(wiimotes[1], 0);

	IplImage* img_src = cvLoadImage("bm.png", CV_LOAD_IMAGE_GRAYSCALE);
    img = cvCreateImage(cvSize(img_src->width,img_src->height), img_src->depth, 1);
	cvThreshold(img_src, img, 128, 255, CV_THRESH_BINARY);	

    cvNamedWindow("input image",CV_WINDOW_AUTOSIZE);
    cvShowImage("input image",img);

	int j;
	for (j = 0; j < 4; j++) {
		/*
		 * motion sensing has to be on to use IR tracking, but uses more battery
		 */
		wiiuse_motion_sensing(wiimotes[j], 1);
		/*
		 * 
		 */
		wiiuse_set_ir(wiimotes[j], 1);
		wiiuse_set_ir_vres(wiimotes[j], 1024, 768); 
		wiiuse_set_aspect_ratio(wiimotes[j], WIIUSE_ASPECT_4_3);	
		/// set to most sensitive level
		wiiuse_set_ir_sensitivity(wiimotes[j],5);
	}


    if (!cvGrabFrame(cap)) { 
        printf("cvGrabFrame failed");
        return -1;
    }

    IplImage* frame = cvRetrieveFrame(cap);

    if (!frame) {
        printf("bad cvRetrieveFrame");
        return -1;
    }

    IplImage* blue = cvCreateImage(cvSize(frame->width,frame->height), frame->depth, 1);
    IplImage* blue_rgb = cvCreateImage(cvSize(frame->width,frame->height), frame->depth, 3);
    cvRectangle(blue_rgb, cvPoint(0,0), cvPoint(blue_rgb->width,blue_rgb->height), CV_RGB(0,0,0), CV_FILLED);

    IplImage* output = cvCreateImage(cvSize(frame->width,frame->height), frame->depth, 3);
    IplImage* hsv = cvCreateImage(cvSize(frame->width,frame->height), IPL_DEPTH_8U, 3);
    IplImage* hue = cvCreateImage(cvSize(frame->width,frame->height), IPL_DEPTH_8U, 1);
    IplImage* var = cvCreateImage(cvSize(frame->width,frame->height), IPL_DEPTH_8U, 1);
    IplImage* msk = cvCreateImage(cvSize(frame->width,frame->height), IPL_DEPTH_8U, 1);
	/*
	 *	This is the main loop
	 *
	 *	wiiuse_poll() needs to be called with the wiimote array
	 *	and the number of wiimote structures in that array
	 *	(it doesn't matter if some of those wiimotes are not used
	 *	or are not connected).
	 *
	 *	This function will set the event flag for each wiimote
	 *	when the wiimote has things to report.
	 */
	while (1) {

        getBlueParts(huemin, huemax, cap, blue, msk, blue_rgb, output, frame, hsv, hue, var);
		
        if (wiiuse_poll(wiimotes, MAX_WIIMOTES)) {
			/*
			 *	This happens if something happened on any wiimote.
			 *	So go through each one and check if anything happened.
			 */
			int i = 0;
			for (; i < MAX_WIIMOTES; ++i) {
				switch (wiimotes[i]->event) {
					case WIIUSE_EVENT:
						/* a generic event occured */
						handle_event(wiimotes[i]);
						break;

					case WIIUSE_STATUS:
						/* a status event occured */
						handle_ctrl_status(wiimotes[i]);
						break;

					case WIIUSE_DISCONNECT:
					case WIIUSE_UNEXPECTED_DISCONNECT:
						/* the wiimote disconnected */
						handle_disconnect(wiimotes[i]);
						break;

					case WIIUSE_READ_DATA:
						/*
						 *	Data we requested to read was returned.
						 *	Take a look at wiimotes[i]->read_req
						 *	for the data.
						 */
						break;

					default:
						break;
				}
			}
		}
	}

	/*
	 *	Disconnect the wiimotes
	 */
	wiiuse_cleanup(wiimotes, MAX_WIIMOTES);

	return 0;
}
