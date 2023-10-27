% Create synthetic objects: dots, lines, shells, rings, balls

% By: Min Guo
% July 29, 2021;

% % *** default settings:
clear all;
% close all;
tStart = tic;
addpath(genpath('.\mFunc\'));
fileFolderOut = 'D:\multiStepDL\SynObj\Obj\';
fileNameBase = 'img_';
imgNumStart = 0;
imgNumEnd = 49;
imgSize = [256, 256, 256];
filterSize = 0.8;
sizeRatio = 1;

if isequal(exist(fileFolderOut, 'dir'),7)
    disp(['output folder:' fileFolderOut]);
else
    mkdir(fileFolderOut);
    disp(['output folder created:' fileFolderOut]);
end

disp('********************************************************');
disp('Start processing ... ... ');
for i = imgNumStart:imgNumEnd
    cTime1 = toc(tStart);
    disp(['Image #: ', num2str(i)]);
    img = create_rd_mix_objects(imgSize, filterSize, sizeRatio);
    WriteTifStack(img,[fileFolderOut, fileNameBase, num2str(i), '.tif'],32);
    cTime2 = toc(tStart);
    disp(['... time cost: ', num2str(cTime2-cTime1)]);
end
cTime = toc(tStart);
disp(['Processing completed!!! Total time cost:', num2str(cTime), ' s']);