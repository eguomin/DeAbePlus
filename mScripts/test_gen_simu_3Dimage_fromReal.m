% Create aberrations and generate aberrated images based on real images

% By: Min Guo
% Sep. 23, 2020;

% % *** default settings:
% clear all;
% close all;
tStart = tic;
addpath(genpath('.\mFunc\'));
flagGPU = 1;
objType = 1; % 1: 0.8NA; 2: 1.1NA; 3: 0.71NA; 4: 1.2NA (confocal) 5: 1.0NA (2P)
lambda = 0.532; % um
pIn = 3:15; % 0: piston; 1:tilt X; 2: tilt Y;
zernNum = length(pIn);
nType = 'poisson'; % 'none', 'gaussian','poisson'
% SNR = 20;
RI = 1.33;
psfChoice = 1; % 0: wide-field; 1: light-sheet; 2: confocal or 2P(normalized)

% % ****** customize aberrations here ****************
% random zernike coefficients, in lenght unit: um
aValue = 0.05; % in length unit: um
zernType = 'random1'; % 'defocus','astig','coma','trefoil','sphe','random1','random2'
spheValueBase = 0.1; % Optional: set low bound of threshold to weight in more large aberrations.
spheValueRange = 0.15;
defocusRange = 0.15;

repNum = 10; % repeat number for each image

flagBg = 0; % do background subtraction: 0.8NA: 1; 1.1NA: 0; 0.71NA: 0
bgValue = 95;
flagSavePSF = 0; % save PSF or not, 1: save; 0: not
LsFWHMz = 2; 
switch objType
    case 1
        NA = 0.8;
        pixelSize = 0.1625; % um
        zStepSize = 1.0; % um
        psfChoice = 1;
        LsFWHMz = 2.5; % light-sheet thickness, unit: um,
    case 2
        NA = 1.1;
        pixelSize = 0.130; % um
        zStepSize = 0.7686; % um
        psfChoice = 1;
        LsFWHMz = 2; % um
    case 3
        NA = 0.71;
        pixelSize =  0.227; % um
        zStepSize = 1.1701; % um
        psfChoice = 1;
        LsFWHMz = 2; % um
    case 4
        NA = 1.2;
        pixelSize =  0.27; % um
        zStepSize = 1.5; % um
        psfChoice = 2;
    case 5
        NA = 1.0;
        pixelSize =  0.12; % um
        zStepSize = 0.5; % um
        psfChoice = 2;
        lambda = 0.960; % um
end

% fileFolderIn = '..\DataForTest\Simu\';
% fileFolderOut = '..\DataForTest\Simu\TestResults\';
fileFolderIn = 'D:\multiStepDL\Embryo\SPIMA\';
fileFolderOut = 'D:\multiStepDL\Embryo\Training_DeAbe\';
fileNameBase = 'SPIMA-';
imgNumStart = 0;
imgNumEnd = 104;
sliceNumStart = 7;
sliceNumEnd = 70;
imgNumOutBase = 0; % modify for each pos folder

imgNumVali = 2;
imgNumValiInterval = 10;

% output folders
fileFolderOutInput = [fileFolderOut, 'GT\'];
fileFolderOutInputMP = [fileFolderOut, 'GT_MP_ZProj\'];
fileFolderOutAbe = [fileFolderOut, 'Aberrated\'];
fileFolderOutAbeMP = [fileFolderOut, 'Aberrated_MP_ZProj\'];
fileFolderOutPSF = [fileFolderOut, 'PSF\'];

fileFolderOutInputCrop = [fileFolderOut, 'GT_Crop\'];
fileFolderOutAbeCrop = [fileFolderOut, 'Aberrated_Crop\'];
fileFolderOutInputCropMP = [fileFolderOut, 'GT_Crop_MP_ZProj\'];
fileFolderOutAbeCropMP = [fileFolderOut, 'Aberrated_Crop_MP_ZProj\'];
fileFolderOutVali = [fileFolderOut, 'Validation\'];
fileFolderOutValiInputCrop = [fileFolderOutVali, 'GT_Crop\'];
fileFolderOutValiAbeCrop = [fileFolderOutVali, 'Aberrated_Crop\'];
fileFolderOutValiInputCropMP = [fileFolderOutVali, 'GT_Crop_MP_ZProj\'];
fileFolderOutValiAbeCropMP = [fileFolderOutVali, 'Aberrated_Crop_MP_ZProj\'];

if isequal(exist(fileFolderOut, 'dir'),7)
    disp(['output folder:' fileFolderOut]);
else
    mkdir(fileFolderOut);
    disp(['output folder created:' fileFolderOut]);
end
mkdir(fileFolderOutInput);
% mkdir(fileFolderOutInputMP);
mkdir(fileFolderOutAbe);
% mkdir(fileFolderOutAbeMP);
mkdir(fileFolderOutPSF);

mkdir(fileFolderOutInputCrop);
mkdir(fileFolderOutAbeCrop);
% mkdir(fileFolderOutInputCropMP);
% mkdir(fileFolderOutAbeCropMP);
mkdir(fileFolderOutVali);
mkdir(fileFolderOutValiAbeCrop);
mkdir(fileFolderOutValiInputCrop);
% mkdir(fileFolderOutValiAbeCropMP);
% mkdir(fileFolderOutValiInputCropMP);

disp('********************************************************');
disp('Start processing ... ... ');
flagSavePSFtrigger = 1;
for i = imgNumStart:imgNumEnd
    cTime1 = toc(tStart);
    disp(['Image #: ', num2str(i)]);
    iOut = i + imgNumOutBase;
    
    % generate phase diversity images;
    fileImgSample = [fileFolderIn, fileNameBase, num2str(i), '.tif'];
    disp('... Generating simulated images...');
    img0 = single(ReadTifStack(fileImgSample));
    % img0 = img0(:,:,1:96);
    [Sx, Sy, Sz] = size(img0);
    % subtract background
    if(flagBg==1)
        img0 = max(img0-bgValue, 0);
    end
    WriteTifStack(img0,[fileFolderOutInput, fileNameBase, num2str(iOut), '.tif'],32);
    WriteTifStack(max(img0,[],3),[fileFolderOutInputMP, fileNameBase, num2str(iOut), '.tif'],32);
    img0Crop = img0(:,:,sliceNumStart:sliceNumEnd);
    
    for j = 0:repNum-1
        coeffs = gen_zern_coeffs(pIn,aValue,zernType); % uniform aberration
        randValue = 2*rand - 1; % [-1, 1]
        spheCoeff = sign(randValue) * spheValueBase + spheValueRange * randValue; % spherical aberration
        coeffs(pIn==12) = spheCoeff;
        randValue = 2*rand - 1; % [-1, 1]
        defocusCoeff = defocusRange*randValue; % defocus aberration
        coeffs(pIn==4) = defocusCoeff;
        
        [imgAbe, PSF_aberrated, PSF_abeFree] = gen_simu_3Dimage_fromReal(img0, pIn, coeffs, pixelSize, ...
            lambda, NA, zStepSize, RI, nType, psfChoice, LsFWHMz);
        
        WriteTifStack(imgAbe,[fileFolderOutAbe, fileNameBase, num2str(iOut),'_', num2str(j), '.tif'],32);
        if(flagSavePSFtrigger==1)
            WriteTifStack(PSF_aberrated,[fileFolderOutPSF, 'PSF_aberrated_', num2str(iOut), '_', num2str(j), '.tif'],32);
            WriteTifStack(PSF_abeFree,[fileFolderOutPSF, 'PSF_abeFree_', num2str(iOut), '_', num2str(j), '.tif'],32);
        end
        % WriteTifStack(max(imgAbe,[],3),[fileFolderOutAbeMP, fileNameBase, num2str(iOut), '_', num2str(j), '.tif'],32);
        
        imgAbeCrop = imgAbe(:,:,sliceNumStart:sliceNumEnd);
        if(mod(i,imgNumValiInterval) == imgNumVali) % pick images for validation
            WriteTifStack(img0Crop,[fileFolderOutValiInputCrop, fileNameBase, num2str(iOut),'_', num2str(j), '.tif'],32);
            WriteTifStack(imgAbeCrop,[fileFolderOutValiAbeCrop, fileNameBase, num2str(iOut),'_', num2str(j), '.tif'],32);
            % WriteTifStack(max(img0Crop,[],3),[fileFolderOutValiInputCropMP, fileNameBase, num2str(iOut), '_', num2str(j), '.tif'],32);
            % WriteTifStack(max(imgAbeCrop,[],3),[fileFolderOutValiAbeCropMP, fileNameBase, num2str(iOut), '_', num2str(j), '.tif'],32);
        else
            WriteTifStack(img0Crop,[fileFolderOutInputCrop, fileNameBase, num2str(iOut),'_', num2str(j), '.tif'],32);
            WriteTifStack(imgAbeCrop,[fileFolderOutAbeCrop, fileNameBase, num2str(iOut),'_', num2str(j), '.tif'],32);
            % WriteTifStack(max(img0Crop,[],3),[fileFolderOutInputCropMP, fileNameBase, num2str(iOut), '_', num2str(j), '.tif'],32);
            % WriteTifStack(max(imgAbeCrop,[],3),[fileFolderOutAbeCropMP, fileNameBase, num2str(iOut), '_', num2str(j), '.tif'],32);
        end
        
    end
    if(flagSavePSF==0) % turn off trigger next time point
        flagSavePSFtrigger = 0;
    end
    cTime2 = toc(tStart);
    disp(['... time cost: ', num2str(cTime2-cTime1)]);
end
cTime = toc(tStart);
disp(['Processing completed!!! Total time cost:', num2str(cTime), ' s']);


