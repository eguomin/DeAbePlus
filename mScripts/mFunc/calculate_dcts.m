function iqm = calculate_dcts(img0, NA, lambda, pixelSize, binSize)
% calculate norm DCTS for 2D or 3D images
% output
%   iqm: image quality metric,
%           single DCTS value if 2D input, DCTS array if 3D input
% input
%   img0: input image
%   NA: ojbective NA
%   lambda: wavelength in um;
%   pixelSize: pixel size in um;

% Feb 23, 2021
% By: Min Guo

if (nargin == 1)
    NA = 0.8;
    lambda = 0.532;
    pixelSize = 0.1625;
    flagBin = 0;
elseif(nargin==4)
    flagBin = 0;
elseif(binSize==1)
    flagBin = 0;
else
    flagBin = 1;
end

imgSize = size(img0);
flag3D = 0; % 1: 3D image; 0: 2D image;
Sx = imgSize(1);
Sy = imgSize(2);
if(length(imgSize)==3)
    Sz = imgSize(3);
    flag3D = 1;
end

% size
if(Sx==Sy)
    Sxy = Sx;
    flagAlignSize = 0;
else
    Sxy = max(Sx,Sy);
    flagAlignSize = 1;
end

% calculate frequency limit
freMax = 2*NA/lambda;
frePixelSize = 1/(pixelSize*Sxy);
frePixelMax = freMax/frePixelSize;
r0 = frePixelMax;

if(flag3D==0)
    if(flagAlignSize==1)
        img = alignsize2d(img0, [Sxy, Sxy]);
    else
        img = img0;
    end
    if(flagBin)
        img = imbin(img, binSize);
    end
    iqm = cal_dcts(img, r0);  
else
    if(flagAlignSize==1)
        img0 = alignsize3d(img0, [Sxy, Sxy, Sz]);
    end
    iqm = zeros(1,Sz);
    for i = 1:Sz
        img = img0(:,:,i);
        if(flagBin)
            img = imbin(img, binSize);
        end
        iqm(i) = cal_dcts(img, r0); 
    end
end

end

function dcts = cal_dcts(imgIn, r0)
% calculate DCTS
imgDCT = dct2(imgIn);
imgNorm = norm(imgDCT);
imgABS = abs(imgDCT/imgNorm);
sumValue = 0;
for i = 1:r0
    for j = 1:r0
        if(i+j<=r0)
            if(imgDCT(i,j)~=0)
                sumValue = sumValue + imgABS(i,j)*log2(imgABS(i,j));
            end
        end
    end
end
dcts = - 2/r0^2*sumValue;
end
        