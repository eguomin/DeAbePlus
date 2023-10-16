function coeffs = wavefront2coeffs(waveFront, p, r,theta, conType)
% wavefront2coeffs is to represent the wavefront by a series of Zernike coefficents with a given single-index p 
% Input
%   waveFront: an wavefront vector to be decomposited to zernike representations.
%   p: a vector of single indexes for Zernike components,
%       elements should be positive integers(>=1)
%   r: a vector of numbers between 0 and 1
%   theta: a vector of angles (rad), has same length with r
%   conType: single-index type, default: ANSI
% 
% Output
%   coeffs: a vector of zernike coefficients

% Note: This file is modified based on zernike_coeffs.m for http://www. 
%       zernfun.m is required for use with this file. It is available here: 
%       http://www.mathworks.com/matlabcentral/fileexchange/7687 

% By: Min Guo
% July 19, 2022

if exist('zernfun.m','file') == 0
    error('zernfun.m does not exist! Please download from mathworks.com and place in the same folder as this file.');
end

if(nargin ==4)
    conType = 'ANSI';
end
[n, m] = zernidx2nm(p, conType);
zernBases = zernfun(n,m,r,theta);

coeffs = pinv(zernBases)*waveFront;

coeffs = coeffs';
