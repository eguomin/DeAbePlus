function Imgs = calc_multiwavefront2PSF(pupilAm, phi0, phi_deltas)
% calculate multiple slice of PSF from multiple wavefronts.
%
% Output
%   Imgs: PSF slices coresponding to input wavefronts
% Input
%   pupilAm: amplitude of pupil function (electric-magnetic field), e.g. disk distribution;
%   phi0: base wavefront (phase); (unit: rad)
%   phi_deltas: delta wavefront (phase); (unit: rad)
%   pixelSize: pixel size of the intensity image

% By: Min Guo
% Mar. 13, 2022
[Sx, Sy, N] = size(phi_deltas);
Imgs = zeros(Sx, Sy, N, 'single');
for i = 1:N
    phi = phi0+phi_deltas(:,:,i);
    pupilFun = pupilAm.*exp(1i.*phi);
    prf = fftshift(ifft2(ifftshift(pupilFun)));
    Imgs(:,:,i) = abs(prf).^2;
end
end