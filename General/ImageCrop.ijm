// Generate Max Intensity Projections (MIP) in batch
// Min Guo, Dec. 2020
macro "MIP_batch [m]"{
run("Close All");
// *** set input and output path based on dialog ***
pathIn = getDirectory("Select input folder");
pathOut = getDirectory("Select output folder");
pathOutMP = pathOut + "MP_ZProj/";
// *** set input and out put path manually ***
//pathIn = "I:/AO_data/DeepLearning/highNA_diSPIM/20201224_Embryo_RW10230_fast/Sample2_1p4um/DL_Expan/Post/";
//pathOut = "I:/AO_data/DeepLearning/highNA_diSPIM/20201224_Embryo_RW10230_fast/Sample2_1p4um/DL_Expan/Post/ZProj/";

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
		// crop
		run("Duplicate...", "duplicate range=1-70");
		saveAs("Tiff", pathOut + fileList[i]);
		// max projection
		// run("Z Project...", "projection=[Max Intensity]");
		// saveAs("Tiff", pathOutMP + "MAX_" + fileList[i]);
		run("Close All");
	}	
}
print("\nProcessing compledted!!!");

}