function pupilMask = circdisk(Sx, Sy)
pupilMask = zeros(Sx, Sy);
r = min(Sx,Sy)/2;
for i = 1:Sx
    for j = 1:Sy
        if (sqrt((i-(Sx+1)/2)^2+ (j-(Sy+1)/2)^2)<= r)
            pupilMask(i,j) = 1;
        end
    end
end
end