function PSF = coeffs2PSF(p,coeffs, Sx, pixelSize, lambda, NA, Sz, zStepSize, RI, normFlag)
% calculate PSF (2D or 3D) from Zernike coefficients (OSA/ANSI convention)
%
% Output
%   PSF: 2D or 3D PSF, maximum value normalized to 1
% Input
%   p: a vector of single indexes(OSA/ANSI convention) for Zernike components,
%       elements should be integers(>=0);
%   coeffs: a vector of Zernike coefficients corresponding to p; (unit: um)
%   Sx: image size x and y of the PSF
%   pixelSize: pixel size of the intensity image
%   lambda: wavelength (should have same unit with pixelSize; (unit: um)
%   NA: numerical aperture of objective
%   Sz: image size z of the PSF
%   zStepSize: z pixel size if for 3D PSF 
%   RI: refractive index if for 3D PSF
%   normFlag: 0: no normalization; 1: normalize maximum to 1; [default: 1]

% By: Min Guo
% Apr. 9, 2020
% Oct. 22, 2020: add normFlag choice
Sy = Sx;
if(nargin==6)
    flag3D = 0; %   flag3D: calculate 2D PSF (0) or 3D PSF (1);
    normFlag = 1;
elseif(nargin==7)
    flag3D = 0;
    normFlag = Sz; % turn Sz to nornFlag
elseif(nargin==9)
    flag3D = 1;
    normFlag = 1;
elseif(nargin==10)
    flag3D = 1;
else
    error('coeffs2PSF: incorrect number of input arguments');
end 

% Zernike coefficients: convert lengh unit(um) to phase unit(pi)
length2phase = 2*pi/lambda;
coeffs = length2phase * coeffs;

% Define the pupil coordinates (Polar coordinate system) 
[r, theta, idx] = def_pupilcoor(Sx, pixelSize, lambda, NA);
r0 = r(idx);
theta0 = theta(idx);

phi = zeros(Sx, Sy, 'single');
phi(idx) = create_wavefront(p,coeffs,r0,theta0); % in phase unit: pi
pupilMask = zeros(Sx, Sy, 'single');
pupilMask(idx) = 1;
pupilFun = pupilMask.*exp(1i*phi);
if(flag3D == 0) % 2D PSF at focal plane
    prf = fftshift(ifft2(ifftshift(pupilFun)));
    PSF = abs(prf).^2;
else % 3D PSF
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
    dConst = 2*pi*RI/lambda*dConst;
    % calculate defocus pupil
    PSF = zeros(Sx,Sy,Sz, 'single');
    Soz = (Sz+1)/2;
    for i = 1:Sz
        zPos = (i - Soz) * zStepSize;
        pupilFun2D = pupilFun .*exp(1i*zPos*dConst);
        prf = fftshift(ifft2(ifftshift(pupilFun2D)));
        PSF(:,:,i) = abs(prf).^2;
    end
    % calculate 3D PSF
    
end
% normalization
if(normFlag==1)
    PSF = PSF/max(PSF(:));
end