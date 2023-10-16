function [n, m] = zernidx2nm(p,conType)
% [n, m] = zernidx2nm(p,conType) converts the order list for Zernike polynomials
% from single-index p to dual-index(n, m).
% 
% Output
%   n: radial order, scale or vector of integer numbers.
%   m: angular frequency, scale or vector of integer numbers.
% Input
%   p: single-index scale or vector of integer numbers.
%   conType: the convention of single-index
%       'ANSI': OSA/ANSI single-index; [default]
%           Thibos, L. N.; Applegate, R. A.; Schwiegerling, J. T.; Webb, R. (2002).
%           "Standards for reporting the optical aberrations of eyes" (PDF). 
%           Journal of Refractive Surgery. 18 (5): S652–60
%       'Fringe': Fringe indices, 'Wyant' + 1;
%       'Wyant': Wyant indices , used in HASO;
%       'NOLL': NOLL indices;
% Note: a LUT can also be created to accelerate the converting.

% By: Min Guo
% July 22, 2020
if(nargin==1)
    conType = 'ANSI'; % defult as OSA/ANSI convention
end

switch conType
    case 'ANSI'
        d = sqrt(9+ 8*p);
        n = ceil((d-3)/2);
        m = 2*p - n.*(n+2);
    case 'Fringe'
        d = floor(sqrt(p-1)) + 1;
        temp1 = d.^2 - p;
        temp2 = mod(temp1,2);
        m = zeros(size(p));
        for i = 1:length(p)
            if temp2(i)==0
                m(i) = temp1(i)/2;
            else
                m(i) = (-temp1(i)-1)/2;
            end
        end
        n = 2*(d-1)-abs(m);
    case 'Wyant'
        p = p+1;
        d = floor(sqrt(p-1)) + 1;
        temp1 = d.^2 - p;
        temp2 = mod(temp1,2);
        m = zeros(size(p));
        for i = 1:length(p)
            if temp2(i)==0
                m(i) = temp1(i)/2;
            else
                m(i) = (-temp1(i)-1)/2;
            end
        end
        n = 2*(d-1)-abs(m);
    case 'NOLL'
        d = ceil((1+sqrt(1+ 8 * p))/2) - 1;
        n = d-1;
        t = floor(d .* (d + 1) ./ 2);
        r = p - t;
        r = r + n;
        m = (-1).^p .* ((mod(n,2)) + 2 * floor((r + mod(n+1,2))/2));
    otherwise
        error('zernidx2nm: wrong convetion type');
end