clear;
clc;
close all;
%% 获取模板excel文件名列表
TemplatesInfoList = dir('C:\Users\shendonghao\Documents\MATLAB\billclassify\project\data\Templates\*.xls');
%% 读取模板信息
for i=1:size(TemplatesInfoList,1)
    template(i)= xlsProcess(TemplatesInfoList(i).name);
end
%% 计算表格表头部分的横纵投影
for i=1:size(template,2)
    %根据模板excel文件中的图片路径，读取图片
    templateImg=imread(template(i).FilePath);
    %计算图像前1/4的纵横投影
    template(i).histogram=templateHistogarm(templateImg,1/4,30);
end
%% 将所有投影存入一个矩阵，用于聚类
for  i=1:size(template,2)
    histogram(i,:)=template(i).histogram;
end
%% 使用Kmeans聚类
[idx,C,sumd,D] = kmeans(histogram,2,'Distance','cosine');
%% 将模板的粗类别存入结构体
for  i=1:size(template,2)
    template(i).cata=idx(i);
end
%% 保存数据
save('templateInfo.mat','template');
save('culsterCenter.mat','C');


