function [dist] = hausdorff( A, B,f1,f2)
% ���������㼯A,B�Ĳ���hausdorff����
% �������A,B�������㼯
% �������f1,f2������hausdorff�����������������
% �������dist�������㼯A,B�Ĳ���hausdorff����
if( size(A,2) ~= size(B,2) )
    fprintf( 'WARNING: dimensionality must be the same\n' );
    dist = [];
    return;
end
dist =max(compute_dist(A,B,f1),compute_dist(B,A,f2));

function[ dist ] = compute_dist( A, B,f )
% ����㼯A���㼯B�����򲿷�hausdorff����
% �������A,B�������㼯
% �������f��A���㼯B�����򲿷�hausdorff����ı�������
% �������dist:�㼯A���㼯B�����򲿷�hausdorff����
m = size(A,1);
n = size(B,1);
dim = size(A,2);
for k = 1 : m
    C = ones(n,1) * A(k,:);
	D = (C-B) .* (C-B);
	D = sqrt( D * ones(dim,1) );
	dist(k) = min(D);
end
dist=shunxu(dist);
dist=dist(uint16(f*m));

function dist=shunxu(dist)
% ������dist��С�����˳������
n=size(dist,2);
for i=1:n-1
    for j=i+1:n
        if dist(i)>=dist(j)
            k=dist(i);
            dist(i)=dist(j);
            dist(j)=k;
        end
    end
end