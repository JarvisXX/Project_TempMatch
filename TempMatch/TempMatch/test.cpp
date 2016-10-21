#include <iostream>
#include <fstream>
#include <cstring>
#include <vector>
#include <iomanip>
#include <cstdlib>
#include <cstdio>
#include <io.h>
#include <cv.h>
#include <highgui.h>
#include <direct.h>
#include <mat.h>
#include "Template.h"

using namespace cv;
using namespace std;

extern double* templateHistogram_30(string fileName, Mat templateImg, double partNum, int binNum);
extern Rect BorderRevised(Rect RectPosition, Mat framegray, int EdgeWidth);
extern double ModHausdorffDist(vector<vector<int>> vec1, vector<vector<int>> vec2);
extern double m_hd(Mat img1, Mat img2);
extern int str2int(string str);
extern void stdSizeShow(string imgName, Mat img);

string double2str(double num){
	stringstream ss;
	string str;
	ss << num;
	ss >> str;
	return str;
}

float str2float(string str){
	stringstream ss;
	float num;
	ss << str;
	ss >> num;
	return num;
}

Mat cRead(string filename){
	ifstream file;
	string filepath = "S:\\Project_TempMatch\\TempMatch\\TempMatch\\";
	string context, cell = ""; //context:each line in csv; cell:each cell in context;
	filename = filepath + filename;
	file.open(filename);
	if (!file){
		cout << "the file isn't exist!" << endl;
		system("pause");
		exit(1);
	}

	getline(file, context);
	int rowNum = str2int(context);
	getline(file, context);
	int colNum = str2int(context);
	Mat result(rowNum, colNum, CV_32FC1);

	int colCount = 0;
	for (int i = 0; i < rowNum; ++i){
		getline(file, context);
		colCount = 0;
		for (int j = 0; j < context.length(); ++j){
			if (context[j] == ','){
				result.at<float>(i, colCount) = str2float(cell);
				++colCount;
				cell = "";
			}
			else
				cell += context[j];
		}
		if (colCount != colNum){
			cout << "Data Error!" << endl;
			system("pause");
			exit(1);
		}
	}

	return result;
}

Template* tRead(string filename, int &tempNum){
	ifstream file;
	string filepath = "S:\\Project_TempMatch\\TempMatch\\TempMatch\\";
	int count = 0, cntrect = 0, pos;//count:count for cell; cntrect:count for rect; pos:position;
	string context, cell = ""; //context:each line in csv; cell:each cell in context;
	filename = filepath + filename;
	file.open(filename);
	if (!file){
		cout << "the file isn't exist!" << endl;
		system("pause");
		exit(1);
	}
	
	getline(file, context);
	tempNum = str2int(context);
	int histCount = 0;
	int rectCount = 0;
	Template *result = new Template[tempNum];
	for (int i = 0; i < tempNum; ++i){
		getline(file, context);
		count = 0;
		histCount = 0;
		rectCount = 0;
		cell = "";
		for (int j = 0; j < context.length(); ++j){
			if (context[j] == ','){
				switch (count){
				case 0: result[i].CompanyName = cell; ++count; break;
				case 1: result[i].DocumentType = cell; ++count; break;
				case 2: result[i].FilePath = cell; ++count; break;
				case 3: result[i].TemplateType = cell; ++count; break;
				case 4:
					if (cell == "FALSE")
						result[i].PageFlag = '0';
					else
						result[i].PageFlag = '1';
					++count; break;
				case 5:
					if (cell == "FALSE")
						result[i].TableFlag = '0';
					else
						result[i].TableFlag = '1';
					++count; break;
				case 6:
					result[i].histCols = str2int(cell);
					result[i].histogram = new double[str2int(cell)];
					++count; break;
				case 7:
					result[i].histogram[histCount] = str2float(cell);
					++histCount;
					if (histCount == result[i].histCols)
						++count;
					break;
				case 8: result[i].cata = str2int(cell); ++count; break;
				case 9:
					result[i].rectNum = str2int(cell);
					result[i].rect = new RECT[str2int(cell)];
					++count; break;
				case 10: result[i].rect[rectCount].pos.x = str2int(cell); ++count; break;
				case 11: result[i].rect[rectCount].pos.y = str2int(cell); ++count; break;
				case 12: result[i].rect[rectCount].pos.width = str2int(cell); ++count; break;
				case 13: result[i].rect[rectCount].pos.height = str2int(cell); ++count; break;
				case 14: result[i].rect[rectCount].FeatureFlag = cell; ++count; break;
				case 15: result[i].rect[rectCount].DatabaseTablename = cell; ++count; break;
				case 16:
					result[i].rect[rectCount].DatabaseColname = cell;
					++rectCount;
					if (rectCount == result[i].rectNum)
						++count;
					else
						count = 10;
				}
				cell = "";
			}
			else cell += context[j];
		}
	}

	return result;
}

int main(){
	//读取样本与聚类类心
	int tempNum;
	Mat C = cRead("clusterCenter.csv");
	Template *templates = tRead("templateInfo.csv", tempNum);

	//读取测试图像，并转为灰度图
	Mat dataTest;
	string TestFile = "D:\\Bill_template\\CIQSJ\\上海化优CIQSJ20160824142854.jpg";
	dataTest = imread(TestFile);
	Mat dataTestGray;
	if (dataTest.channels() > 1)
		cvtColor(dataTest, dataTestGray, CV_RGB2GRAY);
	else
		dataTest.copyTo(dataTestGray);

	//统计表格前partNum部分的横纵投影
	double partNum = (double)1 / 4;
	int binNum = 30;
	double *testHistogram = new double[2 * binNum];
	testHistogram = templateHistogram_30(TestFile, dataTestGray, partNum, binNum);
	/*
	for (int i = 0; i < 2 * binNum; ++i){
		cout << testHistogram[i] << endl;
	}
	system("pause");
	*/

	//根据表头粗分类
	double *distance = new double[C.rows];
	double num, den1, den2;
	double minDistance = DBL_MAX;
	int minC;
	for (int i = 0; i < C.rows; ++i){
		num = den1 = den2 = 0;
		for (int j = 0; j < C.cols; ++j){
			num += testHistogram[j] * C.at<float>(i, j);
			den1 += pow(testHistogram[j], 2);
			den2 += pow(C.at<float>(i, j), 2);
		}
		distance[i] = 1 - num / sqrt(den1 * den2);
		if (distance[i] < minDistance){
			minDistance = distance[i];
			minC = i;
		}
	}
	//cout << minC << endl;
	//coarseIdx用来储存与表头投影距离最近的聚类中心所包含的模板编号
	bool *coarseIdx = new bool[tempNum];
	for (int i = 0; i < tempNum; ++i){
		if (templates[i].cata == minC)
			coarseIdx[i] = true;
		else
			coarseIdx[i] = false;
	}

	//根据唯一性特征框精确查找
	int featureNum = 0;
	int idScore = 0;
	Mat img, framegray;
	Rect tempRectPosition, revisedTempRectPosition;
	Rect dataRectPosition, revisedDataRectPosition;
	Mat tempBox, dataBox;
	Mat display_left, display_right, display;
	double score = 0, minTempScore = DBL_MAX;
	double *tempScore = new double[tempNum];
	for (int i = 0; i < tempNum; ++i)
		tempScore[i] = 0;

	for (int i = 0; i < tempNum; ++i){
		if (!coarseIdx[i])
			continue;
		//cout << "i:" << i << endl;
		cout << "TestFile:" << endl;
		cout << TestFile << endl;
		cout << "DataFile:" << endl;
		cout << templates[i].FilePath << endl;
		img = imread(templates[i].FilePath);
		if (img.channels() > 1)
			cvtColor(img, framegray, CV_RGB2GRAY);
		else
			img.copyTo(framegray);

		featureNum = 0;
		for (int j = 0; j < templates[i].rectNum; ++j){
			if (!strcmp(templates[i].rect[j].FeatureFlag.c_str(), "模板特征")){
				//需要进行矩形框识别
				tempRectPosition = templates[i].rect[j].pos;
				revisedTempRectPosition = BorderRevised(tempRectPosition, framegray, 0); //边界处理
				tempBox = framegray(revisedTempRectPosition); //截取特征框
				//归一化特征框位置
				dataRectPosition.x = int(floor((double)tempRectPosition.x / framegray.cols * dataTestGray.cols));
				dataRectPosition.y = int(floor((double)tempRectPosition.y / framegray.rows * dataTestGray.rows));
				dataRectPosition.width = int(floor((double)tempRectPosition.width / framegray.cols * dataTestGray.cols));
				dataRectPosition.height = int(floor((double)tempRectPosition.height / framegray.rows * dataTestGray.rows));
				//dataRectPosition.width = tempRectPosition.width;
				//dataRectPosition.height = tempRectPosition.height;
				revisedDataRectPosition = BorderRevised(dataRectPosition, dataTestGray, 0);
				dataBox = dataTestGray(revisedDataRectPosition);

				//计算特征框间相似度
				//Harris角点检测
				threshold(tempBox, tempBox, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU);
				threshold(dataBox, dataBox, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU);
				Mat cornerTempBox, cornerDataBox;
				cornerHarris(tempBox, cornerTempBox, 3, 3, 0.01);
				cornerHarris(dataBox, cornerDataBox, 3, 3, 0.01);
				threshold(cornerTempBox, cornerTempBox, 0.08, 255, CV_THRESH_BINARY);
				threshold(cornerDataBox, cornerDataBox, 0.08, 255, CV_THRESH_BINARY);
				
				//记录角点坐标
				vector<vector<int>> tempCorners, dataCorners;
				for (int p = 0; p < cornerTempBox.rows; ++p){
					for (int q = 0; q < cornerTempBox.cols; ++q){
						if (int(cornerTempBox.at<float>(p, q)) == 255){
							vector<int> coordinate(2);
							coordinate[0] = p;
							coordinate[1] = q;
							tempCorners.push_back(coordinate);
						}
					}
				}
				cout << "Temp Corner Number: " << tempCorners.size() << endl;
				for (int p = 0; p < cornerDataBox.rows; ++p){
					for (int q = 0; q < cornerDataBox.cols; ++q){
						if (int(cornerDataBox.at<float>(p, q)) == 255){
							vector<int> coordinate(2);
							coordinate[0] = p;
							coordinate[1] = q;
							dataCorners.push_back(coordinate);
						}
					}
				}
				cout << "Data Corner Number: " << dataCorners.size() << endl;
				
				//计算豪斯多夫距离
				if (dataCorners.size() == 0 || dataCorners.size() == 0)
					score = INFINITY;
				else
					score = ModHausdorffDist(tempCorners, dataCorners);
				cout << "score:" << score << endl;
				//score = m_hd(tempBox, dataBox);
				tempScore[i] += score;

				//显示特征框
				/*
				int colNum = max(tempBox.cols, dataBox.cols);
				int rowNum = max(tempBox.rows, dataBox.rows);
				copyMakeBorder(tempBox, display_left, int(floor((rowNum - tempBox.rows) / 2.0)), int(ceil((rowNum - tempBox.rows) / 2.0)), int(floor((colNum - tempBox.cols) / 2.0)), int(ceil((colNum - tempBox.cols) / 2.0)) + colNum + 10, BORDER_ISOLATED);
				copyMakeBorder(dataBox, display_right, int(floor((rowNum - dataBox.rows) / 2.0)), int(ceil((rowNum - dataBox.rows) / 2.0)), int(floor((colNum - dataBox.cols) / 2.0)) + colNum + 10, int(ceil((colNum - dataBox.cols) / 2.0)), BORDER_ISOLATED);
				add(display_left, display_right, display);
				stdSizeShow("hausdorf distance is "+double2str(score), display);
				*/
				//显示角点图
				/*
				colNum = max(cornerTempBox.cols, cornerDataBox.cols);
				rowNum = max(cornerTempBox.rows, cornerDataBox.rows);
				copyMakeBorder(cornerTempBox, display_left, int(floor((rowNum - cornerTempBox.rows) / 2.0)), int(ceil((rowNum - cornerTempBox.rows) / 2.0)), int(floor((colNum - cornerTempBox.cols) / 2.0)), int(ceil((colNum - cornerTempBox.cols) / 2.0)) + colNum + 10, BORDER_ISOLATED);
				copyMakeBorder(cornerDataBox, display_right, int(floor((rowNum - cornerDataBox.rows) / 2.0)), int(ceil((rowNum - cornerDataBox.rows) / 2.0)), int(floor((colNum - cornerDataBox.cols) / 2.0)) + colNum + 10, int(ceil((colNum - cornerDataBox.cols) / 2.0)), BORDER_ISOLATED);
				add(display_left, display_right, display);
				stdSizeShow("corner", display);
				waitKey(0);
				*/
				++featureNum;
			}
		}
		waitKey(0);
		double FineDistance;
		double num, den1, den2;
		num = den1 = den2 = 0;
		for (int j = 0; j < templates[i].histCols; ++j){
			num += testHistogram[j] * templates[i].histogram[j];
			den1 += pow(testHistogram[j], 2);
			den2 += pow(templates[i].histogram[j], 2);
		}
		FineDistance = 1 - num / sqrt(den1 * den2);
		cout << "FineDistance: " << FineDistance << endl;
		if (featureNum == 0)
			continue;
		tempScore[i] /= featureNum;
		tempScore[i] *= FineDistance;

		if (tempScore[i] < minTempScore){
			minTempScore = tempScore[i];
			idScore = i;
		}
	}
	if (minTempScore <= 2){
		Mat tempMatched = imread(templates[idScore].FilePath);
		Mat dataDisplay(dataTest);
		if (tempMatched.rows - dataTest.rows != 0 || tempMatched.cols - dataTest.cols != 0)
			resize(dataTest, dataDisplay, tempMatched.size(), CV_INTER_LINEAR);
		copyMakeBorder(dataDisplay, display_left, 0, 0, 0, tempMatched.cols + 10, BORDER_ISOLATED);
		copyMakeBorder(tempMatched, display_right, 0, 0, dataDisplay.cols + 10, 0, BORDER_ISOLATED);
		add(display_left, display_right, display);
		stdSizeShow("Result", display);
		waitKey(0);
	}
	else{
		cout << "No Such Templates!" << endl;
		system("pause");
		exit(1);
	}
	
	system("pause");
	return 0;
}
