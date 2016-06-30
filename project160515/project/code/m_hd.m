function d = m_hd(im1, im2)
%% Effect: compute the modified haussdorff distance between 2 bw image 'im1'
%%         and 'im2'
%inputs:
%im1, im2: bw image with the size
%outputs:
%d: the modified haussdorff distance between 'im1' & 'im2'
%Author: Su dongcai at 2012/1/11
%Email: suntree4152@gmail.com, qq:272973536
%reference:
%[1]   D. P. Huttenlocher, G. A. Klanderman, and W.  J. 
%      Rucklidge, “Comparing  images using the Hausdorff 
%      distance”,  IEEE  Trans. PAMI,  vol.  15, pp.  850- 
%      863, 1993.
%[2]  Marie-Pierre Dubisson and A.K.Jain. A modified hausdorff distance for
%     object matching

%0. check inputs:
im_sz1 = size(im1); im_sz2 = size(im2);
if(sum(abs(im_sz1-im_sz2))~=0)
    error('im1 and im2 must with the same size');
end
dist_im1 = bwdist(im1); dist_im2 = bwdist(im2);
% D表示零元素所在的位置靠近非零元素位置的最短距离；
% L则表示在该元素所靠近的最近的非零元的位置；
pidx_im1 = find(im1); pidx_im2 = find(im2);
%eq.(6) in [2]
d12 = mean(dist_im1(pidx_im2));
d21 = mean(dist_im2(pidx_im1));
%eq.(8) in [2]
d = max(d12, d21);