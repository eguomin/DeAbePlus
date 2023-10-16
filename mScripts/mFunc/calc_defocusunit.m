function phiunit = calc_defocusunit(Sx, pixelSize, lambda, NA, RI)
% calculate defocus wavefront unit (rad per um)
%
% Output
%   phiunit: wavefront per micron length
% Input
%   Sx: image size x and y of the PSF
%   pixelSize: pixel size of the intensity image
%   lambda: wavelength (should have same unit with pixelSize; (unit: um)
%   NA: numerical aperture of objective
%   RI: refractive index if for 3D PSF

% By: Min Guo
% Mar. 13, 2020

% Define the pupil coordinates (Polar coordinate system) 
Sy = Sx;
[~, ~, idx] = def_pupilcoor(Sx, pixelSize, lambda, NA);
pupilMask = zeros(Sx, Sy, 'single');
pupilMask(idx) = 1;

freSampling = 1/pixelSize; % length^-1
freSamplingPhase = Sx/freSampling;
pixelSizePhase = 1/freSamplingPhase;
% calculate defocus function: dConst
dConst = zeros(Sx,Sy, 'single');
Sox = (Sx+1)/2; % Sox == Soy
for i = 1:Sx
    for j = 1:Sy
        if(pupilMask(i,j)==1)
            rSQ = (i-Sox)^2 + (j-Sox)^2;
            rSQ = rSQ * pixelSizePhase^2;
            dConst(i,j) = sqrt(1-(lambda/RI)^2*rSQ);
        end
    end
end
phiunit = 2*pi*RI/lambda*dConst;