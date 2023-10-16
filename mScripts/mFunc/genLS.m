function lightSheet = genLS(imSize, LsFWHM, pixelSizexy, pixelSizez, angDeg)
% Create Gaussian-distribution light sheet illumination
% output
%   lightSheet: 3D light sheet illumination
% input
%   imSize: 3D image size [Sx, Sy, Sz] 
%   LsFWHM: FWHM of light sheet, um
%   pixelSizexy: xy pixel size, um
%   pixelSizez: z pixel size, um
%   angDeg: tilt angle of light sheet

% July 8, 2021
% By: Min Guo

Nx = imSize(1);
Ny = imSize(2);
Nz = imSize(3);
lightSheet = zeros(Nx, Ny, Nz, 'single');
sigma = LsFWHM/pixelSizez/2.35482;
if(angDeg ==0)
    z = 1:Nz;
    gaussian_line = exp(-(z-(Nz+1)/2).^2/(2*sigma^2));
    for ix = 1:Nx
        for iy = 1:Ny
            lightSheet(ix,iy,:) = gaussian_line(:);
        end
    end
else
    pr = pixelSizexy/pixelSizez;
    zr = cosd(angDeg);
    yr = sind(angDeg);
    z0 = (Nz+1)/2;
    y0 = (Ny+1)/2;
    PSF_slice = zeros(Ny, Nz, 'single');
    for iz = 1:Nz
        for iy = 1:Ny
            % PSF_slice(iy, iz) = exp(-(((iz-z0)*zr)^2+((iy-y0)*pr*yr)^2)/(2*sigma^2));
            PSF_slice(iy, iz) = exp(-(((iz-z0)*zr+(iy-y0)*pr*yr)^2)/(2*sigma^2));
        end
    end
    for ix = 1:Nx
        lightSheet(ix,:,:) = PSF_slice;
    end
end