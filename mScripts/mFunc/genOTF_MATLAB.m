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