function S = addnoise_getSignal(I0,sType, threPerc)
% get signal level of a image
% output
%   S: image signal
% input
%   I0: input image
%   sType: how to define signal
%       1: maximum intensity of the input image
%       2: average intensity of the input image
%       3: average intensity from pixels with intensity above a threshold
%   perc: if sType = 3, perc is the threshold, default 10%     

% by Min Guo
% Aug 26, 2020
if(nargin == 1)
    sType = 3;
    threPerc = 0.1;
elseif(nargin == 2)
    threPerc = 0.1;
end

% input image signal
switch sType
    case 1
        S = max(I0(:));
    case 2
        S = mean(I0(:));
    case 3
        threValue = mean(I0(:)) * threPerc;
        mask = I0>threValue;
        I_mask = I0 .* mask;
        S = sum(I_mask(:))/sum(mask(:));
    otherwise
        error('addnoiseSNR: wrong signal type');
end