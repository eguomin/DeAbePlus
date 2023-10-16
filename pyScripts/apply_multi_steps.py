# Copyright 2020 DRVision Technologies LLC.
# Creative Commons Attribution-NonCommercial 4.0 International Public License
# (CC BY-NC 4.0) https://creativecommons.org/licenses/by-nc/4.0/

# Modified: Min Guo, 2021-07-14

from rcan.utils import apply, get_model_path, normalize, load_model

import argparse
import functools
import json
import jsonschema
import keras
import numpy as np
import pathlib
import tifffile

from scipy.ndimage import zoom
from scipy.ndimage import rotate

parser = argparse.ArgumentParser()
parser.add_argument('-c', '--config', type=str, required=True)
args = parser.parse_args()

# input json file format
schema = {
    'type': 'object',
    'properties': {
        'COMMENTs': {'type': 'string'}, # comments
        'input_dir': {'type': 'string'}, # file or folder path
        'input_interp_trigger': {'type': 'boolean'}, # interpolate input for demon: using step2_interp_ratio
        'input_interp_dir': {'type': 'string'},
        'input_interp_bit': {'type': 'integer', 'minimum': 8},

        'step1_trigger': {'type': 'boolean'}, # apply step 1
        'step1_model_dir': {'type': 'string'},
        'step1_block_shape': {
            'type': 'array',
            'items': {'type': 'integer', 'minimum': 1},
            'minItems': 2,
            'maxItems': 3
        },
        'step1_output_trigger': {'type': 'boolean'}, # save step 1 result
        'step1_output_dir': {'type': 'string'},
        'step1_output_bit': {'type': 'integer', 'minimum': 8},
        'step1_interp_trigger': {'type': 'boolean'}, # interpolate step1 for demon: using step2_interp_ratio
        'step1_interp_dir': {'type': 'string'},

        'step2_trigger': {'type': 'boolean'},
        'step2_interp_trigger': {'type': 'boolean'},
        'step2_interp_ratio': {
            'type': 'array',
            'items': {'type': 'number', 'minimum': 0.1},
            'minItems': 3,
            'maxItems': 3
        },
        'step2_model_dir': {'type': 'string'},
        'step2_block_shape': {
            'type': 'array',
            'items': {'type': 'integer', 'minimum': 1},
            'minItems': 2,
            'maxItems': 3
        },
        'step2_output_trigger': {'type': 'boolean'},
        'step2_output_dir': {'type': 'string'},
        'step2_output_bit': {'type': 'integer', 'minimum': 8},
        'step3_trigger': {'type': 'boolean'},
        'step3_interp_trigger': {'type': 'boolean'},
        'step3_interp_ratio': {
            'type': 'array',
            'items': {'type': 'number', 'minimum': 0.1},
            'minItems': 3,
            'maxItems': 3
        },
        'step3_model_dir': {'type': 'string'},
        'step3_block_shape': {
            'type': 'array',
            'items': {'type': 'integer', 'minimum': 1},
            'minItems': 2,
            'maxItems': 3
        },
        'step3_output_trigger': {'type': 'boolean'},
        'step3_output_dir': {'type': 'string'},
        'step3_output_bit': {'type': 'integer', 'minimum': 8},
        'scale_value': {'type': 'number'},
        'step1_block_overlap_shape': {
            'type': 'array',
            'items': {'type': 'integer', 'minimum': 1},
            'minItems': 2,
            'maxItems': 3
        },
        'step2_block_overlap_shape': {
            'type': 'array',
            'items': {'type': 'integer', 'minimum': 1},
            'minItems': 2,
            'maxItems': 3
        },
        'step3_block_overlap_shape': {
            'type': 'array',
            'items': {'type': 'integer', 'minimum': 1},
            'minItems': 2,
            'maxItems': 3
        }
    }
}

with open(args.config) as f:
    config = json.load(f)

jsonschema.validate(config, schema)
config.setdefault('scale_value', None)
config.setdefault('step1_block_overlap_shape', None)
config.setdefault('step2_block_overlap_shape', None)
config.setdefault('step3_block_overlap_shape', None)


input_path = pathlib.Path(config['input_dir'])
input_interp_path = pathlib.Path(config['input_interp_dir'])
step1_output_path = pathlib.Path(config['step1_output_dir'])
step1_interp_path = pathlib.Path(config['step1_interp_dir'])
step2_output_path = pathlib.Path(config['step2_output_dir'])
step3_output_path = pathlib.Path(config['step3_output_dir'])

if input_path.is_dir():
    if config['input_interp_trigger'] and not input_interp_path.exists():
        print('Creating input_interp output directory', input_interp_path)
        input_interp_path.mkdir(parents=True)

    if config['step1_trigger'] and config['step1_output_trigger'] and not step1_output_path.exists():
        print('Creating step1 output directory', step1_output_path)
        step1_output_path.mkdir(parents=True)
        if config['step1_interp_trigger'] and not step1_interp_path.exists():
            print('Creating step1_interp output directory', step1_interp_path)
            step1_interp_path.mkdir(parents=True)

    if config['step2_trigger'] and config['step2_output_trigger'] and not step2_output_path.exists():
        print('Creating step2 output directory', step2_output_path)
        step2_output_path.mkdir(parents=True)

    if config['step3_trigger'] and config['step3_output_trigger']:
        if not step3_output_path.exists():
            print('Creating step3 output directory', step3_output_path)
            step3_output_path.mkdir(parents=True)
        step3_output_path2 = step3_output_path / str("Pre_upsample/")
        step3_output_path3 = step3_output_path / str("Post_downsample/")
        if not step3_output_path2.exists():
            step3_output_path2.mkdir(parents=True)
        if not step3_output_path3.exists():
            step3_output_path3.mkdir(parents=True)


if input_path.is_dir():
    data = sorted(input_path.glob('*.tif'))
    # raw_files = sorted(input_path.glob('*.tif'))
    # data = itertools.zip_longest(raw_files, [])   
else:
    data = input_path

if config['step1_trigger']:
    step1_model_path = get_model_path(config['step1_model_dir'])
    print('Loading step1 model from', step1_model_path)
    step1_model = load_model(str(step1_model_path), input_shape=config['step1_block_shape'])

    if config['step1_block_overlap_shape'] is None:
        step1_overlap_shape = [
            max(1, x // 8) if x > 2 else 0
            for x in step1_model.input.shape.as_list()[1:-1]]
    else:
        step1_overlap_shape = config['step1_block_overlap_shape']

if config['step2_trigger']:
    step2_model_path = get_model_path(config['step2_model_dir'])
    print('Loading step2 model from', step2_model_path)
    step2_model = load_model(str(step2_model_path), input_shape=config['step2_block_shape'])

    if config['step2_block_overlap_shape'] is None:
        step2_overlap_shape = [
            max(1, x // 8) if x > 2 else 0
            for x in step2_model.input.shape.as_list()[1:-1]]
    else:
        step2_overlap_shape = config['step2_block_overlap_shape']

if config['step3_trigger']:
    step3_model_path = get_model_path(config['step3_model_dir'])
    print('Loading step3 model from', step3_model_path)
    step3_model = load_model(str(step3_model_path), input_shape=config['step3_block_shape'])

    if config['step3_block_overlap_shape'] is None:
        step3_overlap_shape = [
            max(1, x // 8) if x > 2 else 0
            for x in step3_model.input.shape.as_list()[1:-1]]
    else:
        step3_overlap_shape = config['step3_block_overlap_shape']



if config['scale_value'] is None:
    sValue = 2000
else:
    sValue = config['scale_value']

for raw_file in data:
    print('Loading raw image from', raw_file)
    raw = tifffile.imread(str(raw_file))

    # # # Input interpotation
    if config['input_interp_trigger']:
        print('Scaling size for input (for demon only)')
        result = zoom(raw.astype('float32'), config['step2_interp_ratio'])
        if result.ndim == 4:
            result = np.transpose(result, (1, 0, 2, 3))

        if config['step1_output_bit']  == 8:
            result = np.clip(result, 0, 255).astype('uint8')
        elif config['step1_output_bit']  == 16:
            result = np.clip(result, 0, 65535).astype('uint16') 

        if input_interp_path.is_dir():
            output_file = input_interp_path / raw_file.name
        else:
            output_file = input_interp_path

        print('Saving step1 output image to', output_file)
        tifffile.imwrite(str(output_file), result, imagej=False) 


    # # # Step 1: de-aberration
    if config['step1_trigger']:
        
        print('Applying step1 model')
        raw = normalize(raw)
        restored = apply(step1_model, raw, overlap_shape=step1_overlap_shape, verbose=True)
        restored[restored < 0] = 0

        if config['step1_output_trigger']:
            result = np.stack(restored)
            if result.ndim == 4:
                result = np.transpose(result, (1, 0, 2, 3))

            if config['step1_output_bit']  == 8:
                result = np.clip(sValue * result, 0, 255).astype('uint8')
            elif config['step1_output_bit']  == 16:
                result = np.clip(sValue * result, 0, 65535).astype('uint16') 

            if step1_output_path.is_dir():
                output_file = step1_output_path / raw_file.name
            else:
                output_file = step1_output_path

            print('Saving step1 output image to', output_file)
            tifffile.imwrite(str(output_file), result, imagej=False) 
            
        if config['step1_interp_trigger']:
            print('Scaling size for step1 result (for demon only)')
            result = np.stack(restored)
            result = zoom(result, config['step2_interp_ratio'])
            if result.ndim == 4:
                result = np.transpose(result, (1, 0, 2, 3))

            if config['step1_output_bit']  == 8:
                result = np.clip(sValue * result, 0, 255).astype('uint8')
            elif config['step1_output_bit']  == 16:
                result = np.clip(sValue * result, 0, 65535).astype('uint16') 

            if step1_interp_path.is_dir():
                output_file = step1_interp_path / raw_file.name
            else:
                output_file = step1_interp_path

            print('Saving step1 interp image to', output_file)
            tifffile.imwrite(str(output_file), result, imagej=False) 


    # # # Step 2: deconvolution
    if config['step2_trigger']:
        if config['step1_trigger']:
            raw = restored
        else:
            raw = raw.astype('float32')

        if config['step2_interp_trigger']:
            print('Scaling size for step2')
            raw = zoom(raw, config['step2_interp_ratio'])
        
        print('Applying step2 model')
        raw = normalize(raw)
        restored = apply(step2_model, raw, overlap_shape=step2_overlap_shape, verbose=True)

        restored[restored < 0] = 0

        if config['step2_output_trigger']:
            result = np.stack(restored)
            if result.ndim == 4:
                result = np.transpose(result, (1, 0, 2, 3))

            if config['step1_output_bit']  == 8:
                result = np.clip(sValue * result, 0, 255).astype('uint8')
            elif config['step1_output_bit']  == 16:
                result = np.clip(sValue * result, 0, 65535).astype('uint16') 

            if step2_output_path.is_dir():
                output_file = step2_output_path / raw_file.name
            else:
                output_file = step2_output_path

            print('Saving step2 output image to', output_file)
            tifffile.imwrite(str(output_file), result, imagej=False) 


    # # # Step 3:    
    step3_interp_output_trigger = False
    step3_downsample_output_trigger = True
    if config['step3_trigger']:
        if config['step1_trigger'] or config['step2_trigger']:
            raw = restored
        if config['step3_interp_trigger']:
            print('Scaling size for step3')
            raw = zoom(raw, config['step3_interp_ratio'])
            sValue2 = 1
            if step3_interp_output_trigger:
                if config['step3_output_trigger']:
                    result = np.stack(raw)
                    if result.ndim == 4:
                        result = np.transpose(result, (1, 0, 2, 3))

                    if config['step1_output_bit'] == 8:
                        result = np.clip(sValue2 * result, 0, 255).astype('uint8')
                    elif config['step1_output_bit']  == 16:
                        result = np.clip(sValue2 * result, 0, 65535).astype('uint16') 

                    if step3_output_path2.is_dir():
                        output_file = step3_output_path2 / raw_file.name
                    else:
                        output_file = step3_output_path2
                    print('Saving step3 Pre upsample image to', output_file)
                    tifffile.imwrite(str(output_file), result, imagej=False) # Min: imagej=True --> imagej=False


        print('Applying step3 model')
        raw = normalize(raw)
        restored = apply(step3_model, raw, overlap_shape=step3_overlap_shape, verbose=True)

        restored[restored < 0] = 0

        if config['step3_output_trigger']:
            result = np.stack(restored)
            if result.ndim == 4:
                result = np.transpose(result, (1, 0, 2, 3))

            if config['step1_output_bit'] == 8:
                result = np.clip(sValue * result, 0, 255).astype('uint8')
            elif config['step1_output_bit']  == 16:
                result = np.clip(sValue * result, 0, 65535).astype('uint16') 

            if step3_output_path.is_dir():
                output_file = step3_output_path / raw_file.name
            else:
                output_file = step3_output_path

            print('Saving step3 output image to', output_file)
            tifffile.imwrite(str(output_file), result, imagej=False) # Min: imagej=True --> imagej=False

            if step3_downsample_output_trigger:
                zRatio = config['step3_interp_ratio']
                result = zoom(result, [1/zRatio[0], 1/zRatio[1], 1/zRatio[2]])
                if step3_output_path3.is_dir():
                    output_file = step3_output_path3 / raw_file.name
                else:
                    output_file = step3_output_path3
                print('Saving step3 output downsample image to', output_file)
                tifffile.imwrite(str(output_file), result, imagej=False) # Min: imagej=True --> imagej=False
