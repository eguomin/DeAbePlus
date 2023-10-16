function I = addnoiseScale(I0, nType, scaleR, G)
% scale image and add noise
% output
%   I: image with noise
% input
%   I0: input image
%   nType: noise type - 'gaussian', 'poisson', or 'both'
%   scaleR: scaling ratio
%   G: SD of the Guassian noise
   
% by Min Guo
% June 19, 2020
if(nargin == 2)
    scaleR = 1;
    G = 10;
elseif(nargin == 3)
    G = 10;
end
I_scale = I0 * scaleR;
switch nType
    case 'gaussian'
        [Sx, Sy] = size(I0);
%         I_gauss = imnoise(zeros(Sx,Sy), 'gaussian', 0, 0.04);
        I_gauss = imnoise(zeros(Sx,Sy), 'gaussian', 0.5, 0.01);
        gSD = sqrt(var(I_gauss(:)));
        I_gauss = G/gSD*I_gauss;
        I = I_scale + I_gauss; 
    case 'poisson'
        I = imnoise(uint16(I_scale), 'poisson');
    case 'both' 
        [Sx, Sy] = size(I0);
        I_gauss = imnoise(zeros(Sx,Sy), 'gaussian', 0.5, 0.01);
        gSD = sqrt(var(I_gauss(:)));
        I_gauss = G/gSD*I_gauss;
        I_poisson = double(imnoise(uint16(I_scale), 'poisson'));
        I = I_poisson + I_gauss;
        
    otherwise
        error('snr2signal: wrong noise type');
end
I = single(I);