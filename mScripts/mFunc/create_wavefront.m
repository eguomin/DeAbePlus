function waveFront = create_wavefront(p,coeffs,r,theta,nFlag, conType)
% CREATWAVEFRONT is to creat wavefront based on Zernike coefficients with
% singel-index convention
% Output
%   waveFront: a vector of wavefront for every (r,theta) pair position
% Input
%   p: a vector of single indexes for Zernike components,
%       elements should be positive integers, default: OSA/ANSI convention
%   coeffs: a vector of Zernike coefficients corresponding to p, unit:phase (rad)
%   r: a vector of numbers between 0 and 1
%   theta: a vector of angles (rad), has same length with r
%   nFlag: optional, nflag = 'norm' is corresponding to the normalized Zernike
%       functions

% By: Min Guo
% Dec 09, 2016

if(nargin<=5)
    conType = 'ANSI'; % defult as OSA convention
end

if length(p)~=length(coeffs)
    error('creatwavefront:NMlength','p and coeffs must be the same length.')
end

% [n, m] = zernfringe2nm(p); % modified Jul 27, 2020
[n, m] = zernidx2nm(p, conType);

switch nargin
    case 4
        z = zernfun(n,m,r,theta);
    case 5
        z = zernfun(n,m,r,theta,nFlag);
    case 6
        z = zernfun(n,m,r,theta,nFlag);
    otherwise
        error('zernfun2:nargin','Incorrect number of inputs.')
end
waveFront = zeros(size(r),'single');
for i = 1:length(p)
    waveFront = waveFront + coeffs(i)*z(:,i);
end
    
