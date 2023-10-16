function img = imbin(img0, binSize)
% bin image by binSize x binSize as a block

% output
%   img: binned image
% input
%   img0: input image
%   binSize: block size for binning

% June 19, 2020

binFun = @(block_struct) mean2(block_struct.data);
img = blockproc(img0, [binSize binSize], binFun);
