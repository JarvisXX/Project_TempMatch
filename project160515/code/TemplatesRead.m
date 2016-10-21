clear;
clc;
close all;
%% ��ȡģ��excel�ļ����б�
TemplatesInfoList = dir('C:\Users\shendonghao\Documents\MATLAB\billclassify\project\data\Templates\*.xls');
%% ��ȡģ����Ϣ
for i=1:size(TemplatesInfoList,1)
    template(i)= xlsProcess(TemplatesInfoList(i).name);
end
%% �������ͷ���ֵĺ���ͶӰ
for i=1:size(template,2)
    %����ģ��excel�ļ��е�ͼƬ·������ȡͼƬ
    templateImg=imread(template(i).FilePath);
    %����ͼ��ǰ1/4���ݺ�ͶӰ
    template(i).histogram=templateHistogarm(templateImg,1/4,30);
end
%% ������ͶӰ����һ���������ھ���
for  i=1:size(template,2)
    histogram(i,:)=template(i).histogram;
end
%% ʹ��Kmeans����
[idx,C,sumd,D] = kmeans(histogram,2,'Distance','cosine');
%% ��ģ��Ĵ�������ṹ��
for  i=1:size(template,2)
    template(i).cata=idx(i);
end
%% ��������
save('templateInfo.mat','template');
save('culsterCenter.mat','C');


