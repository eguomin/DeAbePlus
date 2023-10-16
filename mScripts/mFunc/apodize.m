function imgOut = apodize(img, napodize)
% blurs the edges of image to remove the lines artifacts in Fourier domain

imgOut = img;
[ny,nx] = size(img);
% the difference between 0 and the first (1st) row;
diff1 = single(0 - imgOut(1, :));
% the difference between 0 and the last row;
diff2 = single(0 - imgOut(ny, :));
for i = 1: napodize
    fact = single(1 - sin(((i - 0.5) / napodize) * pi * 0.5));
    imgOut(i, :) = imgOut(i, :) + diff1 .* fact;
    imgOut(ny + 1 - i, :) = imgOut(ny + 1 - i, :) + diff2 .* fact;
end

% the difference between 0 and the first (1st) column;
diff1 = single(0 - imgOut(:, 1));
% the difference between 0 and the last column;
diff2 = single(0 - imgOut(:, nx));
for i = 1: napodize
    fact = single(1 - sin(((i - 0.5) / napodize) * pi * 0.5));
    imgOut(:, i) = imgOut(:, i) + diff1 .* fact;
    imgOut(:, nx + 1 - i) = imgOut(:, nx + 1 - i) + diff2 .* fact;
end

end