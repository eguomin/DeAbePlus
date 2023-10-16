function eff = calculate_Eff(I1, I2)
I1 = I1/sum(I1(:));
I2 = I2/sum(I2(:));
I = sqrt(I1).*sqrt(I2);
eff = sum(I(:));
end