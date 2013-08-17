function [clippedImg, xx, yy, shiftVal] = ImageClipper(useImg,bufferzone)
% Adaptive ROI function
% Chris Eckman, SLAC, 2013
%
% inputs:  useImg     = image to be ROI'd        [matrix]
%          bufferzone = buffer zone around image [# of pixels]
%
% outputs: clippedImg = ROI'd image          [matrix]
%          xx         = clipped image X axis [pixels]
%          yy         = clipped image Y axis [pixels]   
%          shiftVal   = shifted center       [# of pixels]

[m n] = size(useImg);
 
mx = max(useImg);
my = max(useImg,[],2);

sorted=sort(my);
idx=find(diff([sorted; sorted(end)-1]));
num=[idx(1); diff(idx)];
ty=sorted(idx(num==max(num)));
ty = ty(end);

[k,zf] = filter([1 -1], 1, double(mx>ty));
k(n+1:n+2-1) = zf;
P = find(k==1);
[L, posP]= max(find(k==-1)-P);
P = P(posP);
tfc = [false(1,P-bufferzone) true(1,L+2*bufferzone) false(1,n-(L+P)-bufferzone)];
yy = find(tfc);

[k,zf] = filter([1 -1], 1, double(my>ty));
k(m+1:m+2-1) = zf;
P = find(k==1);
[L, posP]= max(find(k==-1)-P);%find(k==-1,1,'last')-P
P = P(posP);
tfr = [false(1,P-bufferzone) true(1,L+2*bufferzone) false(1,m-(L+P)-bufferzone)];
shiftVal = P-bufferzone;
xx = find(tfr);

clippedImg = useImg(tfr,tfc);


