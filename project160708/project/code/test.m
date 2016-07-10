% clear;
% clc;
% close all;
%% 读取样本与聚类类心的信息
load('templateInfo.mat','template');
load('culsterCenter.mat','C');
%% 读取测试图像，并转为灰度图
% dataTest = imread...
%     ('C:\Users\shendonghao\Documents\MATLAB\billclassify\project\data\testdata\发票 (4).jpg');
dataTest = imread...
    ('S:\Project_TempMatch\project160708\project\data\20160524测试文件\JH16050077\发票.jpg');
if size(dataTest,3)>1
	dataTestGray=rgb2gray(dataTest);
else 
    dataTestGray=dataTest;
end
%% 统计表格前1/4部分的横纵投影
testHistogram=templateHistogarm(dataTestGray,1/4,30);
%% 根据表头粗分类
%求取表头的投影向量与聚类中心的距离，C是聚类的中心
for i=1:size(C,1)
    distance(i)=pdist([testHistogram;C(i,:)],'cosine');
end
%coarseIdx是与表头投影距离最近的聚类中心所包含的模板编号，即粗筛选出的模板序号
for  i=1:size(template,2)
    idx(i)=template(i).cata;
end
coarseIdx=find(idx==find(distance==min(distance)));

%% 根据唯一性特征框精确查找
tempScore=zeros(size(coarseIdx));
for i=1:max(size(coarseIdx,1),size(coarseIdx,2))
    % 读取模板图像，并转为灰度图
    img = imread(template(coarseIdx(i)).FilePath);
    if  size(img,3) == 3
        framegray = rgb2gray(img);
    else
        framegray = img;
    end
    
    featureNum=0;%统计该模板的特征框个数，用于相似度的归一化
    for K = 1:size(template(coarseIdx(i)).rect,2)
        if strcmp(template(coarseIdx(i)).rect{K}.FeatureFlag,'模板特征')%需要进行识别矩形框
            tempRectPosition = template(coarseIdx(i)).rect{K}.pos;

            [xs,ys] = BorderRevised(tempRectPosition,framegray,0);%边界处理
            tempBox = framegray(ys,xs);%截取特征框
            %归一化特征框位置
            dataRectPosition(1) = floor(tempRectPosition(1)/size(framegray,2)*size(dataTestGray,2));
            dataRectPosition(2) = floor(tempRectPosition(2)/size(framegray,1)*size(dataTestGray,1));
            dataRectPosition(3) = floor(tempRectPosition(3)/size(framegray,2)*size(dataTestGray,2));
            dataRectPosition(4) = floor(tempRectPosition(4)/size(framegray,1)*size(dataTestGray,1));
%             dataRectPosition(3) = tempRectPosition(3);
%             dataRectPosition(4) = tempRectPosition(4);
            [xs,ys] = BorderRevised(dataRectPosition,dataTestGray,0);%边界处理
            dataBox = dataTestGray(ys,xs);%截取特征框
            
            %计算特征框间相似度
%             [x,y,score] = TemplateAndMatching(dataBox,tempBox);
%             score = m_hd(im2bw(tempBox), im2bw(imresize(dataBox,size(tempBox))));%Hausdorff距离
            score = ModHausdorffDist( corner(im2bw(tempBox,graythresh(tempBox)),1000), corner(im2bw(dataBox,graythresh(dataBox)),1000) );
            %使用harris角点提取图像中的特征点，再计算点集间的距离，c++要适当调整阈值，opencv应该有现成函数可调用
            %原理参考http://www.cnblogs.com/ronny/p/4009425.html
%                 /size(corner(im2bw(tempBox,graythresh(tempBox)),500),1);
            tempScore(i)=tempScore(i)+score;       
%             figure();
%             subplot(1,2,1);
%             imshow(dataBox,[]);
%             subplot(1,2,2);
%             imshow( tempBox,[]);
%             title(['hausdorf distance is ' num2str(score)]);
%             title(['corr is ' num2str(score)]);
%             figure(2)
%             imhist(tempBox);

            featureNum=featureNum+1;
        end
    end
    FineDistance(i)=pdist([testHistogram;template(coarseIdx(i)).histogram],'cosine');
    tempScore1(i)=tempScore(i)/featureNum;
    tempScore(i)=tempScore(i)/featureNum*FineDistance(i);
%     tempScore(i)=tempScore(i)/featureNum;%归一化
end

%% 显示结果
idx = find(tempScore==min(tempScore));
if min(tempScore)<=2
    figure();
    subplot(1,2,1);
    imshow(dataTestGray,[]);
    title('input');
    subplot(1,2,2);
    img = imread(template(coarseIdx(idx)).FilePath);
    imshow(img,[]);
    title('output');
else
     error('no such template！');
end


