clear;
clc;
close all;
%% 读取样本与聚类类心的信息
load('templateInfo.mat','template');
load('culsterCenter.mat','C');
%% 读取测试图像，并转为灰度图
dataTest = imread...
    ('S:\Project\project160515\project\data\testdata\发票 (7).jpg');
if size(dataTest,3)>1
	dataTestGray=rgb2gray(dataTest);
else 
    dataTestGray=dataTest;
end
%% 统计表格前1/4部分的横纵投影
testHistogram=templateHistogram(dataTestGray,1/4,30);
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

            [xs,ys] = BorderRevised(tempRectPosition,framegray,10);%边界处理
            tempBox = framegray(ys,xs);%截取特征框
            %归一化特征框位置
            dataRectPosition(1) = floor(tempRectPosition(1)/size(framegray,2)*size(dataTestGray,2));
            dataRectPosition(2) = floor(tempRectPosition(2)/size(framegray,1)*size(dataTestGray,1));
%             dataRectPosition(3) = floor(tempRectPosition(3)/size(framegray,2)*size(dataTestGray,2));
%             dataRectPosition(4) = floor(tempRectPosition(4)/size(framegray,1)*size(dataTestGray,1));
            dataRectPosition(3) = tempRectPosition(3);
            dataRectPosition(4) = tempRectPosition(4);
            [xs,ys] = BorderRevised(dataRectPosition,dataTestGray,10);%边界处理
            dataBox = dataTestGray(ys,xs);%截取特征框
            
            %计算特征框间相似度
%             [x,y,score] = TemplateAndMatching(dataBox,tempBox);
            score = m_hd(im2bw(tempBox), im2bw(dataBox));%Hausdorff距离
%             score = ModHausdorffDist( find(corner(im2bw(tempBox))), find(corner(im2bw(dataBox))) );
            tempScore(i)=tempScore(i)+score;       
            figure();
            subplot(1,2,1);
            imshow(dataBox,[]);
            subplot(1,2,2);
            imshow(tempBox,[]);
            title(['hausdorf distance is ' num2str(score)]);
%             figure(2)
%             imhist(tempBox);

            featureNum=featureNum+1;
        end
    end
%     FineDistance(i)=pdist([testHistogram;template(coarseIdx(i)).histogram],'cosine');
%     tempScore(i)=tempScore(i)/featureNum*FineDistance(i);
        tempScore(i)=tempScore(i)/featureNum;%归一化
end

%% 显示结果
figure();
subplot(1,2,1);
imshow(dataTestGray,[]);
title('input');
subplot(1,2,2);
idx = find(tempScore==min(tempScore));
img = imread(template(coarseIdx(idx)).FilePath);
imshow(img,[]);
title('output');



