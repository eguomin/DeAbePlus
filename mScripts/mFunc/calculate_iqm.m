function iqm = calculate_iqm(img0,mType, binSize)
% calculate image quality metrics

% output
%   iqm: image quality metric
% input
%   img0: input image, same image size in x and y 
%   mType: metric type
%       1: max intensity
%       2: mean intensity
%       3: RMS contrast
%       4: sharpness - image domain
%       5: sharpness - spectral domain 1: 0~r0
%       6: sharpness - spectral domain 2: 0.1*r0~0.5*r0
%       7: norm DCTS  - spectral domain 3: 0~r0

% June 19, 2019
% By: Min Guo
% Last update: Mar 11, 2022
if (nargin == 3)
    flagBin = 1;
    if(binSize==1)
        flagBin = 0;
    end
else
    flagBin = 0;
end
if mType >= 5
    lambda = 0.532;
    pixelSize = 0.08;
    NA = 1.2;
    
    % lambda = 0.532;
    % pixelSize = 0.130;
    % NA = 1.1;
    
    % lambda = 0.960;
    % pixelSize = 0.120;
    % NA = 1.0;
end

if(flagBin)
    img0 = imbin(img0,binSize);
    if mType >= 5
        pixelSize = pixelSize * binSize;
    end
end
switch mType
    case 1
        iqm = max(img0(:));
    case 2
        iqm = mean(img0(:));
    case 3
        [Sx,Sy] = size(img0);
        meanValue = mean(img0(:));
        iqm = norm(img0 - meanValue)/sqrt(Sx*Sy);
    case 4
        [Sx,Sy] = size(img0);
        iqm = norm(img0)/sqrt(Sx*Sy);
    case 5
        [Sx,Sy] = size(img0);
        freMax = 2*NA/lambda;
        frePixelSize = 1/(pixelSize*Sx);
        frePixelMax = freMax/frePixelSize;
        OTF = ifftshift(abs(fft2(img0)));
        totalOTF = sum(OTF(:));
        r2Max = frePixelMax^2;
        Sox = (Sx+1)/2;
        Soy = (Sy+1)/2;
        uOTF = 0;
        for i = 1:Sx
            for j = 1:Sy
                r2 = (i-Sox)^2 + (j-Soy)^2;
                if(r2<=r2Max)
                    uOTF = uOTF + OTF(i,j)*r2;
                end
            end
        end
        iqm = uOTF / totalOTF;
    case 6
        [Sx,Sy] = size(img0);
        freMax = 2*NA/lambda;
        frePixelSize = 1/(pixelSize*Sx);
        frePixelMax = freMax/frePixelSize;
        OTF = ifftshift(abs(fft2(img0)));
        totalOTF = sum(OTF(:));
        r2Max = frePixelMax^2;
        Sox = (Sx+1)/2;
        Soy = (Sy+1)/2;
        uOTF = 0;
        for i = 1:Sx
            for j = 1:Sy
                r2 = (i-Sox)^2 + (j-Soy)^2;
                if((r2<=0.5 *r2Max)&&(r2>0.1*r2Max))
                    uOTF = uOTF + OTF(i,j)*r2;
                end
            end
        end
        iqm = uOTF / totalOTF; 
%         WriteTifStack(log(OTF),'OTF.tif',32);
    case 7
        [Sx,Sy] = size(img0);
        freMax = 2*NA/lambda;
        frePixelSize = 1/(pixelSize*Sx);
        frePixelMax = freMax/frePixelSize;
        r0 = frePixelMax;
        imgDCT = dct2(img0);
        imgNorm = norm(imgDCT);
        imgABS = abs(imgDCT/imgNorm);
%         WriteTifStack(log(imgDCT),'DCT.tif',32);
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
        iqm = - 2/r0^2*sumValue; 
    otherwise
        error('Wrong metric type');
end
        