from __future__ import print_function, unicode_literals, absolute_import, division
import time
import os
os.environ['TF_CPP_MIN_LOG_LEVEL']='2'
os.environ["CUDA_DEVICE_ORDER"] = "PCI_BUS_ID"
os.environ["CUDA_VISIBLE_DEVICES"] = "0"
import numpy as np
import matplotlib.pyplot as plt
## matplotlib inline


##from tifffile import imread
import tifffile as tiff
from csbdeep.utils import axes_dict, plot_some, plot_history
from csbdeep.utils.tf import limit_gpu_memory
from csbdeep.io import load_training_data, save_training_data, save_tiff_imagej_compatible
from csbdeep.models import Config, CARE, IsotropicCARE
from csbdeep.data import RawData, create_patches
from scipy.ndimage import zoom
from scipy.ndimage import rotate
from csbdeep.data.transform import anisotropic_distortions

import argparse
import json
import jsonschema

parser = argparse.ArgumentParser()
parser.add_argument('-c', '--config', type=str, required=True)
args = parser.parse_args()

# input json file format
schema = {
    'type': 'object',
    'properties': {
        'COMMENTS': {'type': 'string'}, # comments
        'training_trigger': {'type': 'boolean'}, # perform training or not
        'training_input_dir': {'type': 'string'}, # folder path
        'training_input_subfolder': {'type': 'string'}, # name of subfolder
        'blur_psf': {'type': 'string'}, # file path and name
        'training_upsample': {'type': 'number'}, # to decimal digit
        'model_dir': {'type': 'string'}, # folder path
        'model_name': {'type': 'string'}, # name of model
        'history_trigger': {'type': 'boolean'}, # plot history curves or not: if true, need to close figure to continue python

        'prediction_trigger': {'type': 'boolean'}, # apply step 1
        'prediction_input_dir': {'type': 'string'},
        'prediction_output_dir': {'type': 'string'},
        'prediction_upsample': {'type': 'number'}, 
        'prediction_output_bit': {'type': 'integer', 'minimum': 8},
    }
}

with open(args.config) as f:
    configin = json.load(f)

jsonschema.validate(configin, schema)
configin.setdefault('prediction_output_bit', 16)

# # # get input parameters
#
training_trigger = configin['training_trigger']
training_input_dir = configin['training_input_dir']
training_input_subfolder = configin['training_input_subfolder']
psf_file = configin['blur_psf']
training_upsample = configin['training_upsample']
model_dir = configin['model_dir']
model_name = configin['model_name']
history_trigger = configin['history_trigger']
#
prediction_trigger = configin['prediction_trigger']
predition_input_dir = configin['prediction_input_dir']
prediction_output_dir = configin['prediction_output_dir']
prediction_upsample = configin['prediction_upsample']
prediction_output_bit = configin['prediction_output_bit']


def training():
    raw_data = RawData.from_folder(
    basepath    = training_input_dir,
    source_dirs = [training_input_subfolder],
    target_dir  = training_input_subfolder,
    axes        = 'ZYX',
    )

    patch_size_set = (1,128,128) # z, y, x (40,64,64)
    patch_number_set = 2000 # 350

    psf = tiff.imread(psf_file)
    anisotropic_transform = anisotropic_distortions(
        subsample=training_upsample, #4.22, # 5.91, #/2, #2.91, # 6.2
        # psf       = np.ones((3,3))/9, # use the actual PSF here
        # psf = np.zeros((3,3))
        #psf=np.array([[0, 1, 0], [0, 1, 0], [0, 1, 0]]) / 3,
        psf = psf,
        psf_axes='YX',
    )

    X, Y, XY_axes = create_patches(
    raw_data            = raw_data,
    patch_size          = patch_size_set,
    n_patches_per_image = patch_number_set,
    transforms = [anisotropic_transform],
    )

    z = axes_dict(XY_axes)['Z']
    X = np.take(X, 0, axis=z)
    Y = np.take(Y, 0, axis=z)
    XY_axes = XY_axes.replace('Z', '')

    assert X.shape == Y.shape
    print("shape of X,Y =", X.shape)
    print("axes  of X,Y =", XY_axes)

    save_training_data(model_dir + '\\' + model_name + '.npz', X, Y, XY_axes)

    (X,Y), (X_val,Y_val), axes = load_training_data(model_dir + '\\' + model_name + '.npz', validation_split=0.1, verbose=True)
    c = axes_dict(axes)['C']
    n_channel_in, n_channel_out = X.shape[c], Y.shape[c]

    config = Config(axes, n_channel_in, n_channel_out, train_epochs = 100, train_steps_per_epoch=100)
    print(config)
    vars(config)
    model = IsotropicCARE(config, model_name, basedir=model_dir)
    history = model.train(X,Y, validation_data=(X_val,Y_val))
    print(sorted(list(history.history.keys())))
    if history_trigger:
        plt.figure(figsize=(16,5))
        plot_history(history,['loss','val_loss'],['mse','val_mse','mae','val_mae'])

def prediction():
    try:
        if not os.path.exists(prediction_output_dir):
            os.makedirs(prediction_output_dir)
    except OSError:
        print ("Creation of the directory %s failed" % prediction_output_dir)
    else:
        print ("Successfully created the directory %s " % prediction_output_dir)

    axes = 'ZYX'
    iso_model = IsotropicCARE(config=None, name=model_name, basedir=model_dir)
    input_labels=os.listdir(predition_input_dir)
    print (input_labels)
    maxlen = len(input_labels)

    for i in range(0,maxlen):
        print('processing.... ' + input_labels[i])
        Predition_File = predition_input_dir + '\\' + input_labels[i]
        input_data = tiff.imread(Predition_File)
        result = iso_model.predict(input_data, axes, prediction_upsample)
        # result = 0.2 * result
        if prediction_output_bit==16:
            tiff.imsave(prediction_output_dir + '\\' + input_labels[i], result.astype('uint16'))
        else:
            tiff.imsave(prediction_output_dir + '\\' + input_labels[i], result)


def main():
    print('Running CARE') 
    if training_trigger:
        training()

    if prediction_trigger:
        prediction()

main()