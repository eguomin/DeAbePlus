function [img3D, PSF] = gen_simu_3Dimage_fromObj(img0, p, coeffs, pixelSize, ...
    lambda, NA, zStepSize, RI, nType, psfChoice, LsFWHMz)
% simulate 3D image based on ground truth image and zernike coefficients
%
% Output
%   img3D: 3D output images
%   PSF: aberrated PSF corresponding to input coeffs
% Input
%   img0: input ground truth image
%   p: a vector of single indexes(OSA/ANSI convention) for Zernike components,
%   coeffs : a matrix (unknown and known phases) of Zernike coefficients; the
%   first dimension corresponding to p;
%   the second dimension should be the image number N; first row is the
%   base or offset coefficients
%   pixelSize: pixel size of the intensity image, unit: um
%   lambda: wavelength, unit: um
%   NA: numerical aperture of objective
%   nType: noise type
%       1)'none': noise free
%       2)'gaussian': Gaussian noise
%       3)'poisson': Poisson noise
%   psfChoice: PSF type, 0: wide-field PSF; 1: light-sheet PSF; 2: two-photon
%   PSF (normalized); 3: confocal PSF
%   LsFWHMz: light-sheet thickness, unit: um

% By: Min Guo
% Apr 10, 2020
% Modified: Aug 2, 2021
[Sx0, Sy0, Sz0] = size(img0);

flagPad = 1;
padx = 128;
pady = 128;
padz = 128;

if(flagPad==1)
    Sx = Sx0 + padx;
    Sy = Sy0 + pady;
    Sz = Sz0 + padz;
    img = alignsize3d(img0, [Sx, Sy, Sz]);
else
    Sx = Sx0;
    Sy = Sy0;
    Sz = Sz0;
    img = img0;
end

% genearate PSFs
PSFx = 128;
% PSFy = FPSFx;
PSFz = 128;
PSF = coeffs2PSF(p,coeffs, PSFx, pixelSize, lambda, NA, PSFz,zStepSize, RI);
if(psfChoice==1)
    PSF = genPSF_wf2ls(PSF, LsFWHMz, zStepSize);
end
if(psfChoice==2)
    PSF = PSF.^2;
end
if(psfChoice==3) % To incorporate
    print('Confocal PSF has not been incorporated to this code.')
end
OTF = genOTF_MATLAB(PSF, [Sx, Sy, Sz]);

% blur image
imgBlur = ConvFFT3_S(img,OTF);

if(flagPad==1)
    imgBlur = alignsize3d(imgBlur, [Sx0, Sy0, Sz0]);
end
imgBlur = max(imgBlur,0);

switch nType
    case 'none'
        img3D = imgBlur;
    case 'gaussian'
        img3D = zeros(Sx0,Sy0,Sz0, 'single');
        for i = 1:Sz0
            img3D(:,:,i) = addgaussiannoise(imgBlur(:,:,i),0.05);
        end
    case 'poisson'
        img3D = zeros(Sx0,Sy0,Sz0, 'single');
        for i = 1:Sz0
            img3D(:,:,i) = addpoissonnoise(imgBlur(:,:,i));
        end
    otherwise
        error('gen_simu_images: wrong noise type');
end

end

% functions for convovlution in Fourier domain
function OTF = genOTF_MATLAB(PSF, imgSize)
% calculate OTF for matlab deconvolution
% % output
% OTF:
% % input 
% PSF: input images
% imSize: image size [Sx,Sy,Sz]
if(nargin==2)
    PSF = single(alignsize3d(PSF, imgSize));
end
PSF = PSF/sum(PSF(:));
OTF = fftn(ifftshift(PSF));
end


function outVol = ConvFFT3_S(inVol,OTF)
    outVol = real(ifftn(fftn(inVol).*OTF));  
end

