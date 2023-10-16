function img2 = alignsize3d(img1,imgSize, padValue)
% align image to a certain size
% % output
% img2: output image
% % input 
% img: input image
% imSize: output image size [Sx2,Sy2,Sz2]
% padValue: value to fill in

if(nargin == 2)
    padValue = 0;
end

[Sx1,Sy1,Sz1] = size(img1);
Sx2 = imgSize(1);
Sy2 = imgSize(2);
Sz2 = imgSize(3);

if(Sx1<Sx2)
    Sox1 = 1;
    Sox2 = round((Sx2-Sx1)/2)+1;
    Sx = Sx1;
else
    Sox1 = round((Sx1-Sx2)/2)+1;
    Sox2 = 1;
    Sx = Sx2;
end

if(Sy1<Sy2)
    Soy1 = 1;
    Soy2 = round((Sy2-Sy1)/2)+1;
    Sy = Sy1;
else
    Soy1 = round((Sy1-Sy2)/2)+1;
    Soy2 = 1;
    Sy = Sy2;
end

if(Sz1<Sz2)
    Soz1 = 1;
    Soz2 = round((Sz2-Sz1)/2)+1;
    Sz = Sz1;
else
    Soz1 = round((Sz1-Sz2)/2)+1;
    Soz2 = 1;
    Sz = Sz2;
end

img2 = ones(Sx2,Sy2,Sz2,'single')*padValue;
img2(Sox2:Sox2+Sx-1,Soy2:Soy2+Sy-1,Soz2:Soz2+Sz-1) = ...
    img1(Sox1:Sox1+Sx-1,Soy1:Soy1+Sy-1,Soz1:Soz1+Sz-1);
end

