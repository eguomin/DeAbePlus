function I = addgaussiannoise(I0,perc)
% There should not be negetive values in I0

Imax = max(I0(:));
I1 = I0/Imax;
sigma = std(I1(:));
v = (sigma*perc)^2;
I1 = imnoise(I1, 'gaussian', 0, v);

I = I1*Imax;
I(I<0) = 0;
