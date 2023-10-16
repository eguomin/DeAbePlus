function [r, theta, idx] = def_pupilcoor(Sx, pixelSize, lambda, NA)
% define the pupil coordinates (Polar coordinate system) 
% based on square image, pixel size, wavelength and NA
% Output
%   r: radial coordinate
%   theta: angular coordinate, rad
%   idx: pupil index
% Input
%   Sx: intensity (or phase) image size, Sy = Sx
%   pixelSize: pixel size of the intensity image
%   lambda: wavelength (should have same unit with pixelSize;
%   NA: numerical aperture of objective

% By: Min Guo
% Jan. 28, 2020

% image size and sampling 
freMax = NA/lambda;% length^-1
freSampling = 1/pixelSize; % length^-1
freSamplingPhase = Sx/freSampling;
pixelSizePhase = 1/freSamplingPhase; % 1/(Sx*pixelSize)

% coordinates
xi = linspace(-round(Sx/2),round(Sx/2),Sx).*pixelSizePhase/freMax; % normalize the coordicators by maximun frequency of the NA 
[X,Y] = meshgrid(xi,xi);
[theta, r] = cart2pol(X,Y);
theta = single(theta);
r = single(r);
idx = r<=1; % 