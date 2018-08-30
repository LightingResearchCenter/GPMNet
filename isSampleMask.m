function [ sampleFound ,img1_double] = isSampleMask( img )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


[bw2,~] = createMask(img);
[x,y] = size(bw2);
persistent se
if isempty(se)
    se = strel('disk',5);
end
bw4 = imclose(bw2,se);
bw5 = imfill(bw4,'holes');


IL = bwlabel(bw5);
R = regionprops(bw5,'Area');
[~,ind] = max([R(:).Area]);

Iout = ismember(IL,ind);
% imshow(Iout);
img1_double = double(Iout);
if sum( img1_double(:)) > .9*x*y
    sampleFound = true;
else
    sampleFound = false;
end
end
