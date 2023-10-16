function PSF = genPSF_gauss(Sx, Sy, Sz, FWHMx,FWHMy,FWHMz)
% Generate 3D Gaussian PSF with FWHM input
if(nargin == 4)
    FWHMy = FWHMx;
    FWHMz = FWHMx;
end
sigx = FWHMx/2.3548;
sigy = FWHMy/2.3548;
sigz = FWHMz/2.3548;
PSF = gen_gaussian3D(Sx, Sy, Sz, sigx,sigy,sigz);