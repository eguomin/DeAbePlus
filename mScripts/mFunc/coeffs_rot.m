function coeffs = coeffs_rot(coeffs0, p, rotAng)
% coeffs_rot is to convert Zernike coefficients by rotating wavefront
% Output
%   coeffs: a vector of Zernike coefficients
% Input
%   p: a vector of single indexes for Zernike components,
%   coeffs0: a vector of input Zernike coefficients corresponding to p
%   r: a vector of numbers between 0 and 1
%   rotAng: rotation angle, unit: degree

% By: Min Guo
% July 19, 2022

xi = -1:1/(128-1/2):1;
[X,Y] = meshgrid(xi,xi);
[theta, r] = cart2pol(X,Y);
idx = r<=1; % 
theta1 = theta + deg2rad(rotAng);

waveFrontVector = create_wavefront(p,coeffs0,r(idx),theta1(idx));
coeffs = wavefront2coeffs(waveFrontVector, p, r(idx),theta(idx));

