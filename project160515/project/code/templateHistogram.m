function histogram=templateHistogram(img,partNum,binNum)
%% 用于求表头的投影
% binNum：横纵投影的bin数
% partNum： 截取前多少作为表头
% histogram：输出的投影向量
normalSize=[600 600];%归一化尺寸
%读图并归一化
if size(img,3)>1
    img=rgb2gray(img);
end
img=imresize(img,[normalSize(1),normalSize(2)]);
%图像二值化
img=im2bw(img,graythresh(img));
%对表头求投影
for j=1:binNum
    count(j)=sum(sum(img(1:floor(normalSize(1)*partNum),(j-1)*floor(normalSize(2)/binNum)+1:j*floor(normalSize(2)/binNum))));
end
histogram(1:binNum)=(count(1:binNum)-min(count(1:binNum)))./max(count(1:binNum));
for j=binNum+1:2*binNum
    count(j)=sum(sum(img((j-binNum-1)*floor(normalSize(1)*partNum/binNum)+1:(j-binNum)*floor(normalSize(1)*partNum/binNum),1:floor(normalSize(2)))));
end
histogram(binNum+1:2*binNum)=(count(binNum+1:2*binNum)-min(count(binNum+1:2*binNum)))./max(count(binNum+1:2*binNum));
