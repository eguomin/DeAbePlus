function coeffs = zerncoeffs(phi, p)
% ZERNCOEFFS is to represent the wavefront by a series of Zernike coefficents with a given single-index p 
% Input
%   phi: an n x n array of phase image to be decomposited to zernike representations.
%       there should not be any NaN element)
%   p: a vector of single indexes(OSA/ANSI convention) for Zernike components,
%       elements should be positive integers(>=1)
% Output
%   coeffs: a vector of zernike coefficients

% Note: This file is modified based on zernike_coeffs.m for http://www. 
%       zernfun.m is required for use with this file. It is available here: 
%       http://www.mathworks.com/matlabcentral/fileexchange/7687 

% By: Min Guo
% Dec 09, 2016

if exist('zernfun.m','file') == 0
    error('zernfun.m does not exist! Please download from mathworks.com and place in the same folder as this file.');
end

x = -1:1/(128-1/2):1;
[X,Y] = meshgrid(x,x);
[theta,r] = cart2pol(X,Y);
idx = r<=1;
z = zeros(size(X));

M = length(p);
% [n, m] = zernfringe2nm(p);% modified Jul. 27, 2020
conType = 'ANSI';
[n, m] = zernidx2nm(p, conType);
y = zernfun(n,m,r(idx),theta(idx));

Zernike = cell(M);
for k = 1:M
    z(idx) = y(:,k);
    Zernike{k} = z;
end

phi_size = size(phi);
if phi_size(1) == phi_size(2)
    phi = phi.*imresize(double(idx),phi_size(1)/256);
    phi = reshape(phi,phi_size(1)^2,1);
    Z = nan(phi_size(1)^2,M);
    for i=1:M
        Z(:,i) = reshape(imresize(Zernike{i},phi_size(1)/256),phi_size(1)^2,1);
    end
    coeffs = pinv(Z)*phi;
else
        error('Input array must be square.');
end