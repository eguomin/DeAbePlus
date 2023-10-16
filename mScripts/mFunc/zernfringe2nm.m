function [n, m] = zernfringe2nm(f)
% ZERNFRINGE2NM converts the order list for Zernike polynomials
% from single-index(Fringe convention) to dual-index(n, m). The Fringe convention is used in Zemax and Hasao v3. For more
% detailed information http://www.jcmwave.com/JCMsuite/doc/html/ParameterReference/0c19949d2f03c5a96890075a6695b258.html
% LOOK UP TABLE(LUT): from 1 to 36
% f: 1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16    17    18    19    20    21    22   23    24    25    26    27    28    29    30    31    32    33    34    35    36
% n: 0     1     1     2     2     2     3     3     4     3     3     4     4     5     5     6     4     4     5     5     6     6    7     7     8     5     5     6     6     7     7     8     8     9     9    10
% m: 0     1    -1     0     2    -2     1    -1     0     3    -3     2    -2     1    -1     0     4    -4     3    -3     2    -2    1    -1     0     5    -5     4    -4     3    -3     2    -2     1    -1     0
% 
% Input
%   f: single-index vector(Fringe convention), order starts at 1.
% Outputs
%   n: order, vector
%   m: frequency, vector
% Note: a LUT can also be created to accelerate the converting(LUT can be created by ZORDER_FRINGE2NM function).

% By: Min Guo
% Dec 09, 2016
d = floor(sqrt(f-1)) + 1;
temp1 = d.^2 - f;
temp2 = mod(temp1,2);
m = zeros(size(f));
for i = 1:length(f)
    if temp2(i)==0
        m(i) = temp1(i)/2;
    else
        m(i) = (-temp1(i)-1)/2;
    end
end
n = 2*(d-1)-abs(m);