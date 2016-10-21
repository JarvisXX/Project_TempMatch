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
	templateImg = imread("S:\\Project_TempMatch\\TempMatch\\data\\TestQ.jpg");
	bin = templateHistogram(templateImg, 0.25, 30);
	for (int i = 0; i < 2 * binNum; ++i){
		cout << bin[i] << endl;
	}
	system("pause");
}