% clear;
% clc;
% close all;
%% ��ȡ������������ĵ���Ϣ
load('templateInfo.mat','template');
load('culsterCenter.mat','C');
%% ��ȡ����ͼ�񣬲�תΪ�Ҷ�ͼ
% dataTest = imread...
%     ('C:\Users\shendonghao\Documents\MATLAB\billclassify\project\data\testdata\��Ʊ (4).jpg');
dataTest = imread...
    ('S:\Project_TempMatch\project160708\project\data\20160524�����ļ�\JH16050077\��Ʊ.jpg');
if size(dataTest,3)>1
	dataTestGray=rgb2gray(dataTest);
else 
    dataTestGray=dataTest;
end
%% ͳ�Ʊ��ǰ1/4���ֵĺ���ͶӰ
testHistogram=templateHistogarm(dataTestGray,1/4,30);
%% ���ݱ�ͷ�ַ���
%��ȡ��ͷ��ͶӰ������������ĵľ��룬C�Ǿ��������
for i=1:size(C,1)
    distance(i)=pdist([testHistogram;C(i,:)],'cosine');
end
%coarseIdx�����ͷͶӰ��������ľ���������������ģ���ţ�����ɸѡ����ģ�����
for  i=1:size(template,2)
    idx(i)=template(i).cata;
end
coarseIdx=find(idx==find(distance==min(distance)));

%% ����Ψһ��������ȷ����
tempScore=zeros(size(coarseIdx));
for i=1:max(size(coarseIdx,1),size(coarseIdx,2))
    % ��ȡģ��ͼ�񣬲�תΪ�Ҷ�ͼ
    img = imread(template(coarseIdx(i)).FilePath);
    if  size(img,3) == 3
        framegray = rgb2gray(img);
    else
        framegray = img;
    end
    
    featureNum=0;%ͳ�Ƹ�ģ���������������������ƶȵĹ�һ��
    for K = 1:size(template(coarseIdx(i)).rect,2)
        if strcmp(template(coarseIdx(i)).rect{K}.FeatureFlag,'ģ������')%��Ҫ����ʶ����ο�
            tempRectPosition = template(coarseIdx(i)).rect{K}.pos;

            [xs,ys] = BorderRevised(tempRectPosition,framegray,0);%�߽紦��
            tempBox = framegray(ys,xs);%��ȡ������
            %��һ��������λ��
            dataRectPosition(1) = floor(tempRectPosition(1)/size(framegray,2)*size(dataTestGray,2));
            dataRectPosition(2) = floor(tempRectPosition(2)/size(framegray,1)*size(dataTestGray,1));
            dataRectPosition(3) = floor(tempRectPosition(3)/size(framegray,2)*size(dataTestGray,2));
            dataRectPosition(4) = floor(tempRectPosition(4)/size(framegray,1)*size(dataTestGray,1));
%             dataRectPosition(3) = tempRectPosition(3);
%             dataRectPosition(4) = tempRectPosition(4);
            [xs,ys] = BorderRevised(dataRectPosition,dataTestGray,0);%�߽紦��
            dataBox = dataTestGray(ys,xs);%��ȡ������
            
            %��������������ƶ�
%             [x,y,score] = TemplateAndMatching(dataBox,tempBox);
%             score = m_hd(im2bw(tempBox), im2bw(imresize(dataBox,size(tempBox))));%Hausdorff����
            score = ModHausdorffDist( corner(im2bw(tempBox,graythresh(tempBox)),1000), corner(im2bw(dataBox,graythresh(dataBox)),1000) );
            %ʹ��harris�ǵ���ȡͼ���е������㣬�ټ���㼯��ľ��룬c++Ҫ�ʵ�������ֵ��opencvӦ�����ֳɺ����ɵ���
            %ԭ��ο�http://www.cnblogs.com/ronny/p/4009425.html
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
%     tempScore(i)=tempScore(i)/featureNum;%��һ��
end

%% ��ʾ���
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
     error('no such template��');
end


