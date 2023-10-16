function img = create_rd_mix_objects(imgSize, filterSize, sizeRatio)

nx = imgSize(1);
ny = imgSize(2);
nz = imgSize(3);

nox = nx/2;
noy = ny/2;
noz = nz/2;

[X,Y,Z] = meshgrid(linspace(-noy,noy,ny),linspace(-nox,nox,nx),linspace(-noz,noz,nz));

img = zeros(ny, nx, nz);

% % dots
nDot = 50;
vMin = 500;
vMax = 4000;
for i=1:nDot
    x0 = randi([1 ny]);
    y0 = randi([1 nx]);
    z0 = randi([1,nz]);
    i0 =  randi([vMin vMax]);
    img(x0,y0,z0) = i0;
end

% % lines
nLine = 150;
vMin = 200;
vMax = 1500;
vLength = round(0.8*nx);
for i=1:nLine
    theta = randi([1 360]); %angle in xy;
    alpha = randi([1 360]); %angle in xz;
    start_x = randi([1 ny]);
    start_y = randi([1 nx]);
    start_z = randi([1 nz]);
    length = randi([1 vLength]);
    i0 =  randi([vMin vMax]);
    lengthXY = abs(length * sind(alpha));
    lengthXZ = abs(length * cosd(alpha));
    end_x = min(max(round(lengthXY * cosd(theta) + start_x),1),nx);
    end_y = min(max(round(lengthXY * sind(theta) + start_y),1),ny);
    
    end_z = min(max(round(lengthXZ + start_z),1),nz);
    
    x = round(linspace(start_x, end_x,length));
    y = round(linspace(start_y, end_y,length));
    z = round(linspace(start_z, end_z,length));
    
    for j=1:length
        img(x(j),y(j),z(j)) = i0;
    end
    
end

% % lines 2: horizontal
nLine = 30;
for i=1:nLine
    theta = randi([1 360]); %angle in xy;
    alpha = 90; %angle in xz;
    start_x = randi([1 ny]);
    start_y = randi([1 nx]);
    start_z = randi([1 nz]);
    length = randi([1 vLength]);
    i0 =  randi([vMin vMax]);
    lengthXY = abs(length * sind(alpha));
    lengthXZ = abs(length * cosd(alpha));
    end_x = min(max(round(lengthXY * cosd(theta) + start_x),1),nx);
    end_y = min(max(round(lengthXY * sind(theta) + start_y),1),ny);
    
    end_z = min(max(round(lengthXZ + start_z),1),nz);
    
    x = round(linspace(start_x, end_x,length));
    y = round(linspace(start_y, end_y,length));
    z = round(linspace(start_z, end_z,length));
    
    for j=1:length
        img(x(j),y(j),z(j)) = i0;
    end
    
end

% % lines 3: vertical
nLine = 30;
vMin = 200;
vMax = 1500;
vLength = round(0.8*nx);
for i=1:nLine
    theta = 90; %angle in xy;
    alpha = randi([1 360]); %angle in xz;
    start_x = randi([1 ny]);
    start_y = randi([1 nx]);
    start_z = randi([1 nz]);
    length = randi([1 vLength]);
    i0 =  randi([vMin vMax]);
    lengthXY = abs(length * sind(alpha));
    lengthXZ = abs(length * cosd(alpha));
    end_x = min(max(round(lengthXY * cosd(theta) + start_x),1),nx);
    end_y = min(max(round(lengthXY * sind(theta) + start_y),1),ny);
    
    end_z = min(max(round(lengthXZ + start_z),1),nz);
    
    x = round(linspace(start_x, end_x,length));
    y = round(linspace(start_y, end_y,length));
    z = round(linspace(start_z, end_z,length));
    
    for j=1:length
        img(x(j),y(j),z(j)) = i0;
    end
    
end

% % balls 
nBall = 100;
sMax = 6;
vMin = 100;
vMax = 800;
vMid = round((vMin + vMax)/2);
for i=1:nBall
    y0 = randi([-noy noy]);
    x0 = randi([-nox nox]);
    z0 = randi([-noz noz]);
    r0 = rand;
    if r0<=0.5
        i0 = randi([vMid vMax]);
    else
        i0 = randi([vMin vMid]);
    end
    r0 = r0 * sMax;
    R = (X-x0).^2 + (Y-y0).^2 + (Z-z0).^2;
    mask = R < r0^2;
    img = img + mask*i0;
end

% % shells //// empty balls
nShell = 100;
sMax = 12;
sT = 1;
vMin = 100;
vMax = 1000;
for i=1:nShell
    y0 = randi([-noy noy]);
    x0 = randi([-nox nox]);
    z0 = randi([-noz noz]);
    r0 = rand;
    i0 = randi([vMin vMax]);
    
    r0 = r0 * sMax;
    
    R = (X-x0).^2 + (Y-y0).^2 + (Z-z0).^2;
    mask = R < r0^2 & R >= (r0-sT)^2;
    img = img + mask*i0;
end

% % rings
[X,Y] = meshgrid(linspace(-noy,noy,ny),linspace(-nox,nox,nx));
nRing = 100;
sMax = 12;
sT = 1;
vMin = 200;
vMax = 1500;
for i=1:nRing
    y0 = randi([-noy noy]);
    x0 = randi([-nox nox]);
    r0 = rand;
    i0 = randi([vMin vMax]);
    
    r0 = r0 * sMax;
    
    R = (X-x0).^2 + (Y-y0).^2;
    mask = R < r0^2 & R >= (r0-sT)^2;
    
    z0 = randi([1 nz]);
    img(:,:,z0) = img(:,:,z0) + mask*i0;
end

if (filterSize>0)
    img = imgaussfilt3(img, filterSize);
end
if(sizeRatio~=1)
    img = imresize3(img, sizeRatio);
end



