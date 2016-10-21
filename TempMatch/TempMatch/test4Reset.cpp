#include <iostream>
#include <cv.h>
#include <highgui.h>

using namespace std;
using namespace cv;

extern void stdSizeShow(string imgName, Mat img);
extern void Reset(Mat srcImg, Mat &dstImg);

int main(){
	//Read a single-channel image
	const char* filename = "S:\\Project_TempMatch\\TempMatch\\data\\ResetTest\\00008.jpg";
	//const char* filename = "S:\\Project_TempMatch\\TempMatch\\data\\ResetTest\\00003.jpg";
	//const char* filename = "S:\\Project_TempMatch\\TempMatch\\data\\ResetTest\\0004.jpg";
	Mat srcImg = imread(filename, CV_LOAD_IMAGE_GRAYSCALE);
	Mat dstImg = Mat::ones(srcImg.size(), CV_8UC3);

	stdSizeShow("source", srcImg);
	Reset(srcImg, dstImg);
	stdSizeShow("result", dstImg);
	waitKey(0);

	imwrite("S:\\Project_TempMatch\\TempMatch\\data\\ResetTest\\imageText_D.jpg", dstImg);

	return 0;
}