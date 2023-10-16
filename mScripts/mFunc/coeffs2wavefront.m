function [waveFront, phaseImg, staPara, puPara] = coeffs2wavefront(p,coeffs,Sx,...
    pixelSize, lambda, NA, flagConfine)
% convert Zernike coefficients (OSA/ANSI convention) to wavefront image
%
% Output
%   waveFront: 2D wavefront image (unit: um)
%   phaseImg: 2D phase image (unit: pi)
%   staPara: statistical parameters: rms, pv
%       pvLength: peak-valley (unit: um)
%       pvPhase: peak-valley (unit: pi)
%       rmsLength: RMS (unit: um)
%       rmsPhase: RMS (unit: pi)
%   puPara: pupil parameters: r, theta, idx
%       r: radial coordinate
%       theta: angular coordinate
%       idx: pupil index
% Input
%   p: a vector of single indexes(OSA/ANSI convention) for Zernike components,
%       elements should be integers(>=0); 
%   coeffs: a vector of Zernike coefficients corresponding to p; (unit: um)
%   Sx: phase image size, Sy = Sx
%   pixelSize: pixel size of the intensity image
%   lambda: wavelength (should have same unit with pixelSize; (unit: um)
%   NA: numerical aperture of objective
%   flagConfine: confine the phase image to 0~2pi;

% By: Min Guo
% Feb. 19, 2020
if(nargin == 6)
    flagConfine = 0;
end

[r, theta, idx] = def_pupilcoor(Sx, pixelSize, lambda, NA);
waveFront = zeros(Sx, Sx, 'single');
phaseImg = zeros(Sx, Sx, 'single');

waveFrontVector = create_wavefront(p,coeffs,r(idx),theta(idx));
length2phase = 2*pi/lambda;
phaseVector = waveFrontVector * length2phase;
if(flagConfine)
    maxValue = 100*pi;
    phaseVector = mod((phaseVector + maxValue),2*pi);
end
waveFront(idx) = waveFrontVector;
phaseImg(idx) = phaseVector;
puPara.r = r;
puPara.theta = theta;
puPara.idx = idx;
staPara.pvLength = max(waveFrontVector) - min(waveFrontVector);
staPara.pvPhase = max(phaseVector) - min(phaseVector);
staPara.rmsLength = rms(waveFrontVector);
staPara.rmsPhase = staPara.rmsLength * length2phase; % rms(phaseVector)
