function coeffs = zernidx2idxcoeffs(p0, coeffs0, conType, zernNumLimit)
% coeffs = zernidx2idxcoeffs(p0, coeffs0, conType, zernNumLimit) converts 
% the order list of Zernike polynomials from p0 to continously defined 
% defined single-indices.
% 
% Output
%   coeffs: a vector of Zernike coefficients continously indexed 
%      from 1 by defined single-indices.
% Input
%   p0: a vector of single-index zernike mode
%   coeffs0: a vector of Zernike coefficients defined by p0 
%   conType: the convention of single-index
%       'ANSI2Wyant': OSA/ANSI indices to Wyant indices; [default]
%       'Wyant2ANSI': Wyant indices to OSA/ANSI indices;
%   zernNumLimit: number of the output coefficients; [default 32 to LabVIEW]

% By: Min Guo
% July 30, 2020
if(nargin==2)
    conType = 'ANSI2Wyant'; % from OSA/ANSI to Wyant (HASO)
end

zernNumIn = length(coeffs0);
p = zernidx2idx(p0, conType);
zernNumMax = max(p(:));
% truncate the output coefficients based on zernNumLimit
if(nargin==4)
    zernNumOut = zernNumLimit;
else
    zernNumOut = zernNumMax;
end
coeffs = zeros(1,zernNumOut);
% re-order the coefficients
for i = 1:zernNumIn
    k = p(i);
    if(k<=zernNumOut)
        coeffs(k) = coeffs0(i);
    end
end

