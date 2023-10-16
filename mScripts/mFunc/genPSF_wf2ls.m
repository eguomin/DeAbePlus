function PSF = genPSF_wf2ls(PSF0, FWHMz, pixelSizez, normFlag)
% convert wide field PSF to light sheet PSF
% output
%   PSF: light sheet PSF
% input
%   PSF0: input wide field PSF
%   FWHMz: FWHM size (thickness) of light sheet
%   pixelSizez: pixel size in z direction
%   normFlag: 0: no normalization; 1: normalize maximum to 1; [default: 1]

if(nargin==3)
    normFlag = 1;
end

[Nx, Ny, Nz] = size(PSF0);
PSF_light_sheet = zeros(Nx, Ny, Nz, 'single');
sigma = FWHMz/pixelSizez/2.35482;
x = 1:Nz;
gaussian_line = exp(-(x-(Nz+1)/2).^2/(2*sigma^2));
for i = 1:Nx
    for j = 1:Ny
        PSF_light_sheet(i,j,:) = gaussian_line(:);
    end
end
PSF = PSF0.*PSF_light_sheet;
% normalization
if(normFlag==1)
    PSF = PSF/max(PSF(:));
end