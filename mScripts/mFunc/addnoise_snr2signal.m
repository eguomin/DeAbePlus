function S = addnoise_snr2signal(r, nType, G)
% calculate signal based on SNR = S/root(S+G^2)

% output
%   S: signal
% input
%   r: SNR value
%   nType: noise type - 'gaussian', 'poisson' or 'both'  
%   G: SD of the Guassian noise

% June 19, 2020
% By: Min Guo
if(nargin == 2)
    G = 10;
end
switch nType
    case 'gaussian'
        S = G * r;
    case 'poisson'
        S = r^2;
    case 'both' % r^2 * (S + G^2) = S^2 --> S^2 - r^2*S - r^2*G^2 = 0
        r2 = r^2;
        G2 = G^2;
        S = (r2 + sqrt(r2^2+4*r2 * G2))/2;
    otherwise
        error('snr2signal: wrong noise type');
end
end
