function I = genGauss(Sx, Sy, Sz, sigx,sigy,sigz)
% Generate 3D Gaussian distribution with sigx,sigy,sigz
sqrSigx = sigx^2*2; 
sqrSigy = sigy^2*2; 
sqrSigz = sigz^2*2; 
Sxo = (Sx+1)/2;
Syo = (Sy+1)/2;
Szo = (Sz+1)/2;
coef = 1/((2*pi)^(3/2)*sigx*sigy*sigz);
I = zeros(Sx,Sy,Sz,'double');
for i=1:Sx
    for j = 1:Sy
        for k = 1:Sz
            d = (i-Sxo)^2/sqrSigx+(j-Syo)^2/sqrSigy+(k-Szo)^2/sqrSigz;
            I(i,j,k) = exp(-d);
        end
    end
end
I = coef*I;