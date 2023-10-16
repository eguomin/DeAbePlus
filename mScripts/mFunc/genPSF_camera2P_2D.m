function [PSF_2P, PSF_Det, PSF_Exc, PSF_Exc2P_ave, PSF_Exc2P_norm]= genPSF_camera2P_2D(p,coeffs, Sx, ...
    pixelSize, lambdaExc,lambdaDet, NA, normFlag)
%
% By: Min Guo
% Oct. 21, 2020

% detection PSF
PSF_Det = coeffs2PSF(p,coeffs, Sx, pixelSize, lambdaDet, NA, normFlag);

% excitation PSF: normalized to aberration-free case
% aberration-free case
coeffs0 = zeros(1,length(p), 'single');
PSF_Exc = coeffs2PSF(p,coeffs0, Sx, pixelSize, lambdaExc, NA, normFlag);
PSF_Exc2P = PSF_Exc.^2;
PSF_Exc2P_ave0 = mean(PSF_Exc2P(:));

PSF_Exc = coeffs2PSF(p,coeffs, Sx, pixelSize, lambdaExc, NA, normFlag);
PSF_Exc2P = PSF_Exc.^2;
PSF_Exc2P_ave = mean(PSF_Exc2P(:));

PSF_Exc2P_norm = PSF_Exc2P_ave/PSF_Exc2P_ave0;
PSF_2P = PSF_Det * PSF_Exc2P_norm;
% normalization
if(normFlag==1)
    PSF_2P = PSF_2P/max(PSF_2P(:));
end