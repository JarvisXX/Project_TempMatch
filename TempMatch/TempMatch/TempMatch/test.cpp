#include <iostream>
#include <iomanip>
#include <cstring>
#include <vector>
#include <cstdlib>
#include <io.h>
#include <cv.h>
#include <highgui.h>
#include <direct.h>
#include <mat.h>
#include "Template.h"
using namespace std;
using namespace cv;

extern double* templateHistogram(Mat templateImg, double partNum, int binNum);

int main(){
	Mat templateImg;
	int binNum = 30;
	double *bin = new double[2*binNum];
	templateImg = imread("S:\\Project\\TempMatch\\TempMatch\\data\\1465596660147.jpg");
	bin = templateHistogram(templateImg, 1, 30);
	system("pause");
}