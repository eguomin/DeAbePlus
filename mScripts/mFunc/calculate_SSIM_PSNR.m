function [sValue, pValue] = calculate_SSIM_PSNR(img1, img0)
% calculate SSIM and PSNR for 2D or 3D images
% output
%   sValue: SSIM (Structural Similarity Index Measure)
%   pValue: PSNR (Peak Signal-to-Noise Ratio)
% input
%   img1: target image
%   img0: reference image

% Aug 16, 2021
% By: Min Guo

% normalize input images
lowL = 0.0002;
upL = 0.9998;
img0_norm = rescale(img0, lowL, upL);
flagDirectNorm = 0;
if(flagDirectNorm == 1)
    img1_norm = rescale(img1, lowL, upL);
else
    covM = cov(img1(:), img0_norm(:));
    a = covM(1, 2) / covM(1,1);
    b = mean(img0_norm(:)) - a * mean(img1(:));
    img1_norm = a * img1 + b;
end

% calculate SSIM and PSNR
sValue = ssim(single(img1_norm),single(img0_norm));
pValue = psnr(single(img1_norm),single(img0_norm));

end

function output_img = rescale(input_img,low_limit,up_limit)

[m1, n1, r1]=size(input_img);
input_img=single(input_img);

arr=sort(reshape(input_img,m1*n1*r1,1));
v_min=arr(ceil(low_limit*m1*n1*r1));
v_max=arr(ceil(up_limit*m1*n1*r1));

output_img=(input_img-v_min)/(v_max-v_min);
end