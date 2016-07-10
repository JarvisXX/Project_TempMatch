function [dist] = hausdorff( A, B,f1,f2)
% 计算两个点集A,B的部分hausdorff距离
% 输入变量A,B：两个点集
% 输入变量f1,f2：部分hausdorff距离的两个比例因子
% 输出变量dist：两个点集A,B的部分hausdorff距离
if( size(A,2) ~= size(B,2) )
    fprintf( 'WARNING: dimensionality must be the same\n' );
    dist = [];
    return;
end
dist =max(compute_dist(A,B,f1),compute_dist(B,A,f2));

function[ dist ] = compute_dist( A, B,f )
% 计算点集A到点集B的有向部分hausdorff距离
% 输入变量A,B：两个点集
% 输入变量f：A到点集B的有向部分hausdorff距离的比例因子
% 输出变量dist:点集A到点集B的有向部分hausdorff距离
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
% 将向量dist从小到大的顺序排列
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