import pathlib
import sys
from collections import defaultdict
import argparse
import numpy as np
import torch
from torch.utils.data import DataLoader
from dataset import SliceDataDev
from architecture import network
import h5py
from tqdm import tqdm
from data import transforms as T

def save_reconstructions(reconstructions, out_dir):
    """
    Saves the reconstructions from a model into h5 files that is appropriate for submission
    to the leaderboard.
    Args:
        reconstructions (dict[str, np.array]): A dictionary mapping input filenames to
            corresponding reconstructions (of shape num_slices x height x width).
        out_dir (pathlib.Path): Path to the output directory where the reconstructions
            should be saved.
    """
    out_dir.mkdir(exist_ok=True)
    for fname, recons in reconstructions.items():
        with h5py.File(out_dir / fname, 'w') as f:
            f.create_dataset('reconstruction', data=recons)

def create_data_loaders(args):

    data = SliceDataDev(args.data_path,'4x','calgary')
    data_loader = DataLoader(
        dataset=data,
        batch_size=args.batch_size,
        num_workers=1,
        pin_memory=True,)

    return data_loader


def load_model(checkpoint_file):

    checkpoint = torch.load(checkpoint_file)
    args = checkpoint['args']

    dccoeff = 0.1
    wacoeff = 0.1
    cascade = 3

    model = network(dccoeff,wacoeff,cascade).to(args.device)
    model.load_state_dict(checkpoint['model'])

    return model


def run_unet(args, model, data_loader):

    model.eval()
    reconstructions = defaultdict(list)
    with torch.no_grad():
        for (iter,data) in enumerate(tqdm(data_loader)):

            img_gt,img_und,img_und_kspace,rawdata_und,masks,sensitivity,slices,fnames = data

            img_gt  = img_gt.float().to(args.device)
            img_und = img_und.float().to(args.device)
            img_und_kspace = img_und_kspace.float().to(args.device)
            rawdata_und = rawdata_und.float().to(args.device)
            masks = masks.float().to(args.device)
            sensitivity = sensitivity.float().to(args.device)
            
            output = model(img_und,img_und_kspace,rawdata_und,masks,sensitivity)
            recons = T.complex_abs(output).to('cpu')

            for i in range(recons.shape[0]):
                recons[i] = recons[i] 
                reconstructions[fnames[i]].append((slices[i].numpy(), recons[i].numpy()))

    reconstructions = {
        fname: np.stack([pred for _, pred in sorted(slice_preds)])
        for fname, slice_preds in reconstructions.items()
    }

    return reconstructions


def main(args):
    
    data_loader = create_data_loaders(args)
    model = load_model(args.checkpoint)
    reconstructions = run_unet(args, model, data_loader)
    save_reconstructions(reconstructions, args.out_dir)


def create_arg_parser():

    parser = argparse.ArgumentParser(description="Valid setup for MR recon U-Net")
    parser.add_argument('--checkpoint', type=pathlib.Path, required=True,
                        help='Path to the U-Net model')
    parser.add_argument('--out-dir', type=pathlib.Path, required=True,
                        help='Path to save the reconstructions to')
    parser.add_argument('--batch-size', default=16, type=int, help='Mini-batch size')
    parser.add_argument('--device', type=str, default='cuda', help='Which device to run on')
    parser.add_argument('--data-path',type=str,help='path to validation dataset')
    
    return parser

if __name__ == '__main__':
    args = create_arg_parser().parse_args(sys.argv[1:])
    main(args)
