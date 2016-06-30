function histogram=templateHistogram(img,partNum,binNum)
%% �������ͷ��ͶӰ
% binNum������ͶӰ��bin��
% partNum�� ��ȡǰ������Ϊ��ͷ
% histogram�������ͶӰ����
normalSize=[600 600];%��һ���ߴ�
%��ͼ����һ��
if size(img,3)>1
    img=rgb2gray(img);
end
img=imresize(img,[normalSize(1),normalSize(2)]);
%ͼ���ֵ��
img=im2bw(img,graythresh(img));
%�Ա�ͷ��ͶӰ
for j=1:binNum
    count(j)=sum(sum(img(1:floor(normalSize(1)*partNum),(j-1)*floor(normalSize(2)/binNum)+1:j*floor(normalSize(2)/binNum))));
end
histogram(1:binNum)=(count(1:binNum)-min(count(1:binNum)))./max(count(1:binNum));
for j=binNum+1:2*binNum
    count(j)=sum(sum(img((j-binNum-1)*floor(normalSize(1)*partNum/binNum)+1:(j-binNum)*floor(normalSize(1)*partNum/binNum),1:floor(normalSize(2)))));
end
histogram(binNum+1:2*binNum)=(count(binNum+1:2*binNum)-min(count(binNum+1:2*binNum)))./max(count(binNum+1:2*binNum));
