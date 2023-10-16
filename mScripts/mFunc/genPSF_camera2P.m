function [PSF_2P, PSF_Det, PSF_Exc, PSF_Exc2P_ave]= genPSF_camera2P(p,coeffs, Sx, ...
    pixelSize, lambdaExc,lambdaDet, NA, Sz, zStepSize, RI, normFlag, flagPupilMatch)
%
% By: Min Guo
% Oct. 21, 2020
Sy = Sx;

% detection PSF
PSF_Det = coeffs2PSF(p,coeffs, Sx, pixelSize, lambdaDet, NA, Sz,zStepSize, RI, normFlag);

% excitation PSF
if(flagPupilMatch==1)
    PSF_Exc = coeffs2PSF(p,coeffs, Sx, pixelSize, lambdaExc, NA, ...
        Sz,zStepSize, RI, normFlag);
else
    PSF_Exc = coeffs2PSF_unmatachPupil(p,coeffs, Sx, pixelSize, lambdaExc, NA, ...
        Sz,zStepSize, RI, normFlag, lambdaDet);
end
PSF_Exc2P = PSF_Exc.^2;
PSF_Exc2P_ave = ones(Sx, Sy, Sz, 'single');
sliceTemp = ones(Sx, Sy, 'single'); 
PSF_Exc2P_ave_line = 1:Sz;
for i = 1:Sz
    iSlice = PSF_Exc2P(:,:,i);
    meanValue = mean(iSlice(:));
    PSF_Exc2P_ave_line(i) = meanValue;
    PSF_Exc2P_ave(:,:,i) = meanValue * sliceTemp;
end
PSF_2P = PSF_Det .* PSF_Exc2P_ave;
% normalization
if(normFlag==1)
    PSF_2P = PSF_2P/max(PSF_2P(:));
end