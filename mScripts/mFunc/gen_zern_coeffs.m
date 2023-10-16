function c = gen_zern_coeffs(p,aValue,zernType,zernIdx,zernValue)
% create zernike coefficient vector
%
% ouput
%   c: zernike coefficient vector corrsponding to zernike index p
% input 
%   p: a vector of zernike index (OSA/ANSI convention)
%   aValue: value of the coefficient (maximum) amplitude.
%   zernType: how to generate coefficient
%       'zero': a vector of zeros
%       'defocus': Z4 = aValue
%       'astig': Z5 = aValue
%       'coma': Z8 = aValue
%       'trefoil': Z9 = aValue
%       'sphe': Z12 = aValue
%       'random1': random values with uniform weight for all indices
%           (tilts and defocus excluded)
%       'random2': random values with higher weight for lower order indices
%           (tilts and defocus excluded)
%       'idx': specify zernike indices with specified values (zernIdx and
%       zernValue
%   zernIdx and zernValue: zernike indices and values for 'idx' option

% By: Min Guo
% Aug 5, 2020

zernNum = length(p);
pStart = p(1);
c = zeros(1,zernNum, 'single');
switch zernType
    case 'zero'
    case 'defocus'
        c(p==4) = aValue;
    case 'astig'
        c(p==5) = aValue;
    case 'coma'
        c(p==8) = aValue; 
    case 'trefoil'
        c(p==9) = aValue; 
    case 'sphe'
        c(p==12) = aValue; 
    case 'random1'
        a = -aValue; b = aValue;
        cRandom = a + (b-a).*rand(1,zernNum); 
        c = cRandom;
        c(p==1) = 0; % exclude tilt1;
        c(p==2) = 0; % exclude tilt2;
        c(p==4) = 0; % exclude defocus;
    case 'random2'
        a1 = -aValue; b1 = aValue;
        cLength1 = 14-p(1) + 1; % Z14
        cRandom1 = a1 + (b1-a1).*rand(1,cLength1);
        a2 = a1/2; b2 = b1/2;
        cRandom2 = a2 + (b2-a2).*rand(1,zernNum - cLength1);
        c(1:cLength1) = cRandom1(:);
        c(cLength1+1:zernNum) = cRandom2(:);
        c(p==1) = 0; % exclude tilt1;
        c(p==2) = 0; % exclude tilt2;
        c(p==4) = 0; % exclude defocus;
    case 'idx'
        c(zernIdx-pStart+1) = zernValue; 
    otherwise
        disp('gen_zern_coeffs: wrong zernType, zero vector is used')
end
c = single(c);
