// Generate Max Intensity Projections (MIP) in batch
// Min Guo, Dec. 2020
macro "MIP_batch [m]"{
run("Close All");
// *** set input and output path based on dialog ***
pathIn = getDirectory("Select input folder");
pathOut = getDirectory("Select output folder");
pathOutMP = pathOut + "MP_ZProj/";
// *** set input and out put path manually ***
//pathIn = "D:/multiStepDL/Embryo/SPIMA/";
//pathOut = "D:/multiStepDL/Embryo/SPIMA_crop/";
//pathOutMP = pathOut + "MP_ZProj/";

fileSuffix = ".tif"; // suffix or extension of file names
fileList = getFileList(pathIn);
totalFileNum = lengthOf(fileList);
File.makeDirectory(pathOut);
// File.makeDirectory(pathOutMP);
print("Total File Number: " + totalFileNum);
// Array.sort(fileList);
setBatchMode(true);
for (i = 0; i < totalFileNum; i++) {
	if(endsWith(fileList[i], fileSuffix)){
		print(fileList[i]);
		open(pathIn + fileList[i]);
		
		// crop XY 
		makeRectangle(356, 19, 320, 448); // Pos2
		run("Crop");
		
		// crop Z
		sliceStart = 25; // Pos0: 25; Pos1: ;Pos2:
		sliceEnd = 38; // Pos0: 38; Pos1: ; Pos2:
		run("Duplicate...", "duplicate range="+ sliceStart + "-" + sliceEnd);
		saveAs("Tiff", pathOut + fileList[i]);
		// max projection
		// run("Z Project...", "projection=[Max Intensity]");
		// saveAs("Tiff", pathOutMP + "MAX_" + fileList[i]);
		run("Close All");
	}	
}
print("\nProcessing compledted!!!");

}