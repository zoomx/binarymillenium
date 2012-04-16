#include "opencv2/video/tracking.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"

#include <iostream>

using namespace cv;
using namespace std;

void help()
{
	cout <<
			"\nThis program demonstrates dense optical flow algorithm by Gunnar Farneback\n"
			"Mainly the function: calcOpticalFlowFarneback()\n"
			"Call:\n"
			"./fback\n"
			"This reads from video camera 0\n" << endl;
}
void drawOptFlowMap(const Mat& flow, Mat& cflowmap, int step,
                    double, const Scalar& color)
{
  cv::Mat log_flow, log_flow_neg;
  //log_flow = cv::abs( flow/3.0 );
  cv::log(cv::abs(flow)*3 + 1, log_flow);
  cv::log(cv::abs(flow*(-1.0))*3 + 1, log_flow_neg);
  const float scale = 64.0;
  const float offset = 128.0;
  
  float max_flow = 0.0;

    for(int y = 0; y < cflowmap.rows; y += step)
        for(int x = 0; x < cflowmap.cols; x += step)
        {
            const Point2f& fxyo = flow.at<Point2f>(y, x);
            Point2f& fxy = log_flow.at<Point2f>(y, x);
            const Point2f& fxyn = log_flow_neg.at<Point2f>(y, x);

            if (fxyo.x < 0) {
              fxy.x = -fxyn.x; 
            }
            if (fxyo.y < 0) {
              fxy.y = -fxyn.y; 
            }


            cv::Scalar col = cv::Scalar(offset + fxy.x*scale, offset + fxy.y*scale, offset);
            //line(cflowmap, Point(x,y), Point(cvRound(x+fxy.x), cvRound(y+fxy.y)),
            //     color);
            circle(cflowmap, Point(x,y), 0, col, -1);

            if (fabs(fxy.x) > max_flow) max_flow = fabs(fxy.x);
            if (fabs(fxy.y) > max_flow) max_flow = fabs(fxy.y);
        }

  std::cout << max_flow << " max flow" << std::endl;
}

int main(int argc, char* argv[])
{
    
    Mat prevgray, gray, flow, cflow, frame;
    namedWindow("flow", 1);
   
    prevgray = imread(argv[1], 0);
    gray = imread(argv[2],0);

    //cvtColor(l1, prevgray, CV_BGR2GRAY);
    //cvtColor(l2, gray, CV_BGR2GRAY);

    {
        
        if( prevgray.data )
        {
            const float pyrScale = 0.5;
            const float levels = 3;
            const float winsize = 15;
            const float iterations = 3;
            const float polyN = 5;
            const float polySigma = 1.2;
            const int flags = 0;
            // TBD need sliders for all these parameters
            calcOpticalFlowFarneback(
                prevgray, 
                gray, 
                flow, 
                pyrScale, //0.5, 
                levels, //3, 
                winsize, //15, 
                iterations, //3, 
                polyN, //5, 
                polySigma, //1.2,
                flags //0
                );
            cvtColor(prevgray, cflow, CV_GRAY2BGR);
            //drawOptFlowMap(flow, cflow, 16, 1.5, CV_RGB(0, 255, 0));
            drawOptFlowMap(flow, cflow, 1, 1.5, CV_RGB(0, 255, 0));
            //imshow("flow", cflow);
            imwrite(argv[3],cflow);
        }
        
        //waitKey(0);
        //std::swap(prevgray, gray);
    }
    return 0;
}
