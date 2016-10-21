#include <iostream>
#include <cv.h>
#include <highgui.h>
#include <direct.h>

using namespace std;
using namespace cv;

extern string int2str(int num);

double* templateHistogram_30(string fileName, Mat templateImg, double partNum, int binNum){
	Mat img;
	CvSize normalSize;
	//��һ���ߴ�
	normalSize.height = 600;
	normalSize.width = 600;
	//OTSU��ֵ��
	if (templateImg.channels() > 1)
		cvtColor(templateImg, img, CV_RGB2GRAY);
	else
		templateImg.copyTo(img);
	resize(img, img, normalSize, CV_INTER_LINEAR);
	//imshow("��һ���ߴ�", img);
	//waitKey(0);
	threshold(img, img, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU);
	Rect oneQuarter(0, 0, img.cols, int(floor(img.rows*partNum)));
	//imshow("��ֵ��", img(oneQuarter));
	//waitKey(0);

	int *count = new int[binNum];
	double *histogram = new double[2 * binNum];
	int minCount = INT_MAX, maxCount = 0;
	for (int i = 0; i < binNum; ++i)
		count[i] = 0;

	//�Ա�ͷ��ͶӰ
	//��ͶӰ
	fileName = fileName.substr(0, fileName.size() - 4);
	mkdir(fileName.c_str());
	for (int k = 0; k < binNum; ++k){
		//Rect piece(k * int(floor(normalSize.width / binNum)), 0, int(floor(normalSize.width / binNum)), int(floor(normalSize.height * partNum)));
		//string pieceFile = fileName + "\\" + int2str(k) + ".jpg";
		//imwrite(pieceFile, img(piece));
		for (int i = 0; i < int(floor(normalSize.height * partNum)); ++i){
			for (int j = k * int(floor(normalSize.width / binNum)); j < (k + 1) * int(floor(normalSize.width / binNum)); ++j){
				count[k] += int(img.at<uchar>(i, j));
			}
		}
		if (count[k] < minCount)
			minCount = count[k];
		if (count[k] > maxCount){
			maxCount = count[k];
		}
	}
	if (maxCount == minCount){
		for (int k = 0; k < binNum; ++k){
			histogram[k] = 1.0;
		}
	}
	else{
		for (int k = 0; k < binNum; ++k){
			histogram[k] = double(count[k] - minCount) / (maxCount - minCount);
		}
	}

	//��ʼ��
	for (int i = 0; i < binNum; ++i)
		count[i] = 0;
	//��ͶӰ
	minCount = INT_MAX; maxCount = 0;
	for (int k = 0; k < binNum; ++k){
		//Rect piece(0, k * int(floor(normalSize.height * partNum / binNum)), normalSize.width, int(floor(normalSize.height * partNum / binNum)));
		//string pieceFile = fileName + "\\" + int2str(binNum + k) + ".jpg";
		//imwrite(pieceFile, img(piece));
		for (int i = k * int(floor(normalSize.height * partNum / binNum)); i < (k + 1) * int(floor(normalSize.height * partNum / binNum)); ++i){
			for (int j = 0; j < normalSize.width; ++j){
				count[k] += int(img.at<uchar>(i, j));
			}
		}
		if (count[k] < minCount)
			minCount = count[k];
		if (count[k] > maxCount){
			maxCount = count[k];
		}
	}
	if (maxCount == minCount){
		for (int k = binNum; k < 2 * binNum; ++k){
			histogram[k] = 1.0;
		}
	}
	else{
		for (int k = binNum; k < 2 * binNum; ++k){
			histogram[k] = double(count[k - binNum] - minCount) / (maxCount - minCount);
		}
	}

	//system("pause");
	return histogram;
}