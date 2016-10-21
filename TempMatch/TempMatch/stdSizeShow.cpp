#include <iostream>
#include <cv.h>
#include <highgui.h>

using namespace std;
using namespace cv;

void stdSizeShow(string imgName, Mat img){
	Mat display(img);
	if (display.cols > 1000){
		CvSize size;
		size.width = 1000;
		size.height = int(floor((double)1000 / display.cols * display.rows));
		resize(display, display, size, CV_INTER_LINEAR);
	}
	if (display.rows > 600){
		CvSize size;
		size.height = 600;
		size.width = int(floor((double)600 / display.rows * display.cols));
		resize(display, display, size, CV_INTER_LINEAR);
	}
	imshow(imgName, display);
}