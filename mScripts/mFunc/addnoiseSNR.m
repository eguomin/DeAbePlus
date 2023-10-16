function I = addnoiseSNR(I0,nType,r, G, sType, threPerc)
% Add noise based on signal to noise ratio (SNR).
% Functions addnoise_snr2signal, addnoise_getSignal and addnoiseScale are required.
% output
%   I: image with noise
% input
%   I0: input image
%   nType: noise type - 'gaussian', 'poisson', or 'both'
%   r: SNR
%   G: SD of the Guassian noise
%   sType: how to define signal
%       1: maximum intensity of the input image
%       2: average intensity of the input image
%       3: average intensity from pixels with intensity above a threshold
%   perc: if sType = 3, perc is the threshold, default 10% 
     
% by Min Guo
% June 4, 2020
% Modified: Aug 26, 2020

if(nargin == 3)
    G = 10;
    sType = 3;
    threPerc = 0.1;
elseif(nargin == 4)
    sType = 3;
    threPerc = 0.1;
elseif(nargin == 5)
    threPerc = 0.1;
end

% desired signal level
S = addnoise_snr2signal(r, nType, G);

% input image signal
S0 = addnoise_getSignal(I0, sType, threPerc);

% image scaling ratio
scaleR = S/S0;

% add noise
I = addnoiseScale(I0, nType, scaleR, G);
end