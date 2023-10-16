function p = zernidx2idx(p0, conType)
% p = zernnm2idx(pIn, conType) converts the order list for Zernike polynomials
% from single-index p0 to single-index p.
% 
% Output
%   p: single-index scale or vector of integer numbers.
% Input
%   p0: single-index scale or vector of integer numbers.
%   conType: the convention of single-index
%       'ANSI2Wyant': OSA/ANSI indices to Wyant indices; [default]
%       'ANSI2Fringe': OSA/ANSI single-index to Fringe indices;
%       'Wyant2ANSI': Wyant indices to OSA/ANSI indices;
%       'Fringe2ANSI': Fringe indices to OSA/ANSI indices;
%       'Wyant2Fringe': Wyant indices to Fringe indices;
%       'Fringe2Wyant': Fringe indices to Wyant indices;
%       'ANSI2NOLL': OSA/ANSI indices to NOLL indices;
%       'NOLL2ANSI': NOLL indices to OSA/ANSI indices;
% Note: a LUT can also be created to accelerate the converting.

% By: Min Guo
% July 22, 2020
if(nargin==1)
    conType = 'ANSI2Wyant'; % defult as OSA/ANSI convention
end

switch conType
    case 'ANSI2Wyant'
        [n,m] = zernidx2nm(p0,'ANSI');
        p = zernnm2idx(n,m,'Wyant');
    case 'ANSI2Fringe'
        [n,m] = zernidx2nm(p0,'ANSI');
        p = zernnm2idx(n,m,'Fringe');
    case 'Wyant2ANSI'
        [n,m] = zernidx2nm(p0,'Wyant');
        p = zernnm2idx(n,m,'ANSI');
    case 'Fringe2ANSI'
        [n,m] = zernidx2nm(p0,'Fringe');
        p = zernnm2idx(n,m,'ANSI');
    case 'Wyant2Fringe'
        p = p0 + 1;
    case 'Fringe2Wyant'
        p = p0 - 1;
    case 'ANSI2NOLL'
        [n,m] = zernidx2nm(p0,'ANSI');
        p = zernnm2idx(n,m,'NOLL');
    case 'NOLL2ANSI'
        [n,m] = zernidx2nm(p0,'NOLL');
        p = zernnm2idx(n,m,'ANSI');
    otherwise
        error('zernidx2idx: wrong convetion type');
end