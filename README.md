# DeAbePlus

[![License: CC BY-NC 4.0](https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc/4.0/)

DeAbePlus includes a series of computational techniques of deaberration and resolution enhancement for fluorescence microscopy based on deep learning. It is a companion code to our paper: XXXXX
 
![Example](.\General\DeAbe.jpg)

## System Requirements

- Windows 10 or Linux OS. 
- NVIDIA GPU: supported by CUDA 10. Most nowadays graphics card from Nvidia should be compatible with CUDA 10, but better [check here](https://developer.nvidia.com/cuda-gpus).
- CUDA 10.0 and cuDNN 7.6.5

### Dependencies

- Python: version 3.7.0 or later.
- MATLAB: version R2020b or later.
- 3D-RCAN: a 3D version of deep residual channel attention network (RCAN). Open resources can be found from [this Github repository](https://github.com/AiviaCommunity/3D-RCAN). 
- CARE: a toolbox for content-aware restoration (CARE) of (fluorescence) microscopy images. Installation and introduction can be found on [this website](https://csbdeep.bioimagecomputing.com/doc/).
- diSPIMFusion: a code package to perform deconvolution and multiview fusion for microscopy images. Installation and introduction can be found on [this Github repository](https://github.com/eguomin/diSPIMFusion).

### Tested Environment

- Windows 10 workstation
    - CPU: Intel Xeon, Platinum 8369B, two processors; 
    - RAM: 256 GB; 
    - GPU: NVIDIA GeForce RTX 3090 with 24 GB memory; 
- Python 3.7.0 
- MATLAB R2022b.

### Installation

Install from Github:
`git clone https://github.com/neurodata/mgcpy`

### Dataset
 
 A dataset for training and test is available at [Zenodo wibesite](https://zenodo.org/record/8424246), along with pre-trained models.

## How to use

### 1. DeAbe model

- Model training
        
    1) Crop and extract the shallow subvolumes from the raw image stacks using the ImageJ macro `ImageCrop.ijm` within Fiji. 
   
    2) Generate the degraded images from the shallow subvolumes with synthetical aberrations using `test_gen_simu_3Dimage.m` within MATLAB.

    3) Train the DeAbe model using `cmd_train_DeAbe.bat` within 3D-RCAN.
    
- Model apply

    Run the code `cmd_apply_DeAbe.bat`.

### 2. Multi-step Pipeline

- Model training
        
    Step 1: train the **DL DeAbe** model as described above. 
        
    Step 2: train the **DL Decon** model. 
        
     1) Joint deconvolve the multiview images (after applying DeAbe model) using `diSPIMFusion` code to get goundtruth for the Decon model training.

     2) Using de-aberrated images (after applying DeAbe model) and groundtruth images (after joint deconvolution) as training data pairs, train the Decon model by code `cmd_train_Decon.bat` within 3D-RCAN.

    Step 3: train the **DL Iso** model or **DL Expan** model.
    
    - **DL Iso** model

        Run the code `cmd_CARE_iso.bat` with the parameter "training_trigger" as *true* and "prediction_trigger" as *false*.

    - **DL Expan** model

        1) Generate expansion training data pairs with code `expanded_embryo_sythetic.m` as described in paper [[1]](#3). 
        
        2) Run the code `cmd_train_Exapn.bat` within 3D-RCAN.


    
- Model apply

    - If Step 3 is **DL Iso** model:
    
    1) Run the code `cmd_apply_multi_steps.bat` with Parameters "step1_trigger" and "step2_trigger" as *true*, and "step3_trigger" as *false*.

    2) Run the code `cmd_CARE_iso.bat` with the parameter "training_trigger" as *false* and "prediction_trigger" as *true*.

    - If Step 3 is **DL Expan** model:
    
        Run the code `cmd_apply_multi_steps.bat` with Parameters "step1_trigger", "step2_trigger" and "step3_trigger" all set as *true*.


## References

<a id="1">[1]</a>
Jiji Chen, *et al*. (2021).
"[Three-dimensional residual channel attention networks denoise and sharpen fluorescence microscopy image volumes](https://www.nature.com/articles/s41592-021-01155-x)." Nature Methods 18 (2021): 678–687