% depth-dependent decay correction
% exponential function: I = I*exp(a*x);

% decay coeff = 0.08;
% bgValue = 394;
% pathMain = 'Y:\MG\AO_Project\DeepLearning\ConfocalEv\SpinDisk\MoreApply\';

dcoeff = 0.01;
bgValue = 0;
pathIn = 'D:\multiStepDL\ClearedTissue\raw\488\';
pathOut = 'D:\multiStepDL\ClearedTissue\input\488\';
mkdir(pathOut);
fileName = 'img_5.tif';
fileIn = [pathIn, fileName];
fileOut = [pathOut, fileName];
img0 = single(ReadTifStack(fileIn));
img0 = max(img0 - bgValue, 0);
[Sx, Sy, Sz] = size(img0);
img = zeros(Sx, Sy, Sz, 'single');
for i = 1: Sz
    img(:,:,i) = img0(:,:,i) * exp(i*dcoeff);
end
WriteTifStack(img, fileOut, 16);