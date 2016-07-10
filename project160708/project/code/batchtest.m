clear;
clc;
close all;

load('templateInfo.mat','template');
load('culsterCenter.mat','C');

dataTestInfoList = dir('C:\Users\shendonghao\Documents\MATLAB\billclassify\project\data\testdata\*.jpg');

for i=1:size(dataTestInfoList,1)
    i
    dataTest= imread(dataTestInfoList(i).name);
    [CompanyName,DocumentType,FilePath]=TemplateSearch(dataTest,template,C);
end
