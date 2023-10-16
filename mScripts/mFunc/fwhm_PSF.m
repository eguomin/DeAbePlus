function [FWHMx,FWHMy,FWHMz] = fwhm_PSF(PSF, pixelSize, cFlag, fitFlag)
% Feed back the full width at half maximun of the input PSF
% fwhm.m and mygaussfit.m are needed
% cFlag
%       0: use maximum's position as PSF center position
%       1: use matrix's center position as PSF center position
% fitFlag
%       0: no fitting before calculate FWHM
%       1: spine fitting before calculate FWHM
%       2: gaussian fitting before calculate FWHM
% 
if(nargin == 1)
    pixelSize = 1;
    cFlag = 0;
    fitFlag = 0;
end

if(nargin == 2)
    cFlag = 0;
    fitFlag = 0;
end

if(nargin == 3)
    fitFlag = 0;
end

% PSF = PSF - mean(PSF(:));
[Sx,Sy,Sz] = size(PSF);
if((Sx ==1)||(Sy==1)) % 1D input
    x = 1:max(Sx,Sy);
    x = x';
    y = PSF(:);
    FWHMx = fwhm(x, y);
    FWHMy = 0;
    FWHMz = 0;
    else if(Sz == 1) % 2D input
        if(cFlag)  
            indx = floor((Sx+1)/2);
            indy = floor((Sy+1)/2);
        else
            [~, ind] = max(PSF(:)); % find maximum value and position 
            [indx,indy] = ind2sub([Sx,Sy],ind(1));
        end
     
        x = 1:Sx;
        x = x';
        y = PSF(:,indy);
        y = y(:);
        if(fitFlag==1)
            xq = 1:0.1:Sx;
            yq = interp1(x, y, xq, 'spline');
            FWHMx = fwhm(xq, yq);
        elseif(fitFlag==2)
            [sig,~,~] = mygaussfit(x,y);
            FWHMx = sig*2.3548;
        else
            FWHMx = fwhm(x, y);
        end
       
        
        x = 1:Sy;
        x = x';
        y = PSF(indx,:);
        y = y(:);
        if(fitFlag==1)
            xq = 1:0.1:Sx;
            yq = interp1(x, y, xq, 'spline');
            FWHMy = fwhm(xq, yq);
        elseif(fitFlag==2)
            [sig,~,~] = mygaussfit(x,y);
            FWHMy = sig*2.3548;
        else
            FWHMy = fwhm(x, y);
        end
     
        FWHMz = 0;
     else % 3D input
         if(cFlag)  
            indx = floor((Sx+1)/2);
            indy = floor((Sy+1)/2);
            indz = floor((Sz+1)/2);
        else
            [~, ind] = max(PSF(:)); % find maximum value and position 
            [indx,indy,indz] = ind2sub([Sx,Sy,Sz],ind(1));
        end
        
        
        x = 1:Sx;
        x = x';
        y = PSF(:,indy,indz);
        y = y(:);
        if(fitFlag==1)
            xq = 1:0.1:Sx;
            yq = interp1(x, y, xq, 'spline');
            FWHMx = fwhm(xq, yq);
        elseif(fitFlag==2)
            [sig,~,~] = mygaussfit(x,y);
            FWHMx = sig*2.3548;
        else
            FWHMx = fwhm(x, y);
        end
        x = 1:Sy;
        x = x';
        y = PSF(indx,:,indz);
        y = y(:);
        if(fitFlag==1)
            xq = 1:0.1:Sy;
            yq = interp1(x, y, xq, 'spline');
            FWHMy = fwhm(xq, yq);
        elseif(fitFlag==2)
            [sig,~,~] = mygaussfit(x,y);
            FWHMy = sig*2.3548;
        else
            FWHMy = fwhm(x, y);
        end
        
        x = 1:Sz;
        x = x';
        y = PSF(indx,indy,:);
        y = y(:);
        if(fitFlag==1)
            xq = 1:0.1:Sz;
            yq = interp1(x, y, xq, 'spline');
            FWHMz = fwhm(xq, yq);
        elseif(fitFlag==2)
            [sig,~,~] = mygaussfit(x,y);
            FWHMz = sig*2.3548;
        else
            FWHMz = fwhm(x, y);
        end
%         FWHMz = fwhm(x, y);
    end
end

FWHMx = FWHMx*pixelSize;
FWHMy = FWHMy*pixelSize;
FWHMz = FWHMz*pixelSize;