#UNETGAN
import logging
import pathlib
import random
import shutil
import time
import functools
import numpy as np
import torch
import torchvision
from torch import nn, optim
from torch.nn import functional as F
from torch.utils.data import DataLoader
from tensorboardX import SummaryWriter
#from mri_data import SliceData, SliceDataDev
from dataset import SliceData, SliceDataDev
from models import UNet, Discriminator
from sewar.full_ref import vifp
from tqdm import tqdm
import argparse
from skimage.measure import compare_psnr
from skimage.measure import compare_ssim
from architecture import DnCnRefine
from utils import complex_abs

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def create_datasets(args):
    train_data = SliceData(args.train_path, args.acceleration, args.dataset_type)
    dev_data = SliceData(args.val_path, args.acceleration, args.dataset_type)
    return dev_data, train_data


def create_data_loaders(args):
    dev_data, train_data = create_datasets(args)
    display_data = [dev_data[i] for i in range(0, len(dev_data), len(dev_data) // 16)]
    train_loader = DataLoader(
        dataset=train_data,
        batch_size=args.batch_size,
        #shuffle=False,
        #num_workers=64,
        pin_memory=True,
    )
    dev_loader = DataLoader(
        dataset=dev_data,
        batch_size=args.batch_size,
        #num_workers=64,
        pin_memory=True,
    )
    display_loader = DataLoader(
        dataset=display_data,
        batch_size=4,
        num_workers=64,
        pin_memory=True,
    )
    return train_loader, dev_loader, display_loader

def train_epoch(args, epoch, model, netD, data_loader, optimizer, optimizerD, writer):
    model.train()

    start_epoch = start_iter = time.perf_counter()
    global_step = epoch * len(data_loader)

    #criterion_bce = nn.BCEWithLogitsLoss()
    criterion_L1 = nn.L1Loss()

    start_epoch = start_iter = time.perf_counter()
    global_step = epoch * len(data_loader)
    for iter, data in enumerate(tqdm(data_loader)):
        #input, target, coord = data
        input, kspace, target = data

        input = input.to(args.device)
        kspace = kspace.to(args.device)
        target = target.to(args.device)

        input = input.float()
        target = target.float()
        kspace = kspace.float()

        #batch_size = input.shape[0]
        #print (input.shape, kspace.shape,target.shape)
        outG = model(input,kspace)

        outG = complex_abs(outG.permute(0,2,3,1)) 
        target = complex_abs(target.permute(0,2,3,1))

        outG = outG.unsqueeze(1)
        target = target.unsqueeze(1)

        # Discriminator update
        #Enable backprop for D
        for param in netD.parameters():
            param.requires_grad = True

        optimizerD.zero_grad()

        pred_fake = netD(outG.detach())
        #fake_label = torch.ones(pred_fake.shape).to(args.device)
        #loss_D_fake = criterion_bce(pred_fake, fake_label)
        loss_D_fake = torch.mean(pred_fake)

        pred_real = netD(target)
        #real_label = torch.zeros(pred_real.shape).to(args.device)
        #loss_D_real = criterion_bce(pred_real, real_label)
        loss_D_real = - torch.mean(pred_real)

        lossD = (loss_D_fake + loss_D_real) * 0.5
        lossD.backward()
        optimizerD.step()

        #Generator Update

        #Disable backprop for D
        for param in netD.parameters():
            param.requires_grad = False

        optimizer.zero_grad()
        pred_fake = netD(outG)
        lossG_gan = - torch.mean(pred_fake)

        #lossG_gan = criterion_bce(pred_fake, real_label) 

        lossG_l1 = criterion_L1(outG, target) 

        #print (lossG_gan, lossG_l1, loss_D_real, loss_D_fake)
        #print (args.adv_weight)
        lossG = lossG_gan * args.adv_weight   + lossG_l1 
        lossG.backward()

        optimizer.step()

        writer.add_scalar('GenLoss', lossG.item(), global_step + iter)
        writer.add_scalar('DiscLoss', lossD.item(), global_step + iter)
        writer.add_scalar('L1Loss', lossG_l1.item(), global_step + iter)
        writer.add_scalar('Advloss', lossG_gan.item(), global_step + iter)
        writer.add_scalar('loss_D_real', loss_D_real.item(), global_step + iter)
        writer.add_scalar('loss_D_fake', loss_D_fake.item(), global_step + iter)
        #break
        
    return lossG.item(), lossD.item(),  time.perf_counter() - start_epoch


def evaluate(args, epoch, model, data_loader, writer):
    model.eval()

    losses_psnr = []
    losses_vif  = []
    losses_ssim = []

    start = time.perf_counter()
    with torch.no_grad():
        for iter, data in enumerate(tqdm(data_loader)):
            #input, target, coords, fm, slice= data
            input, kspace, target = data

            input = input.to(args.device)
            kspace = kspace.to(args.device)
            target = target.to(args.device)

            input = input.float()
            target = target.float()
            kspace = kspace.float()
         
            output = model(input,kspace)

            output = complex_abs(output.permute(0,2,3,1)) 
            target = complex_abs(target.permute(0,2,3,1))

            output = output.cpu().numpy()
            target = target.cpu().numpy()

            output = np.transpose(output,[1,2,0])
            target = np.transpose(target,[1,2,0])

            loss = vifp(target, output)
            losses_vif.append(loss)
 
            loss = compare_psnr(target, output, data_range=target.max())
            losses_psnr.append(loss)

            loss = compare_ssim(target, output, multichannel=True)
            losses_ssim.append(loss)
             
            #break
        writer.add_scalar('Dev_Loss_psnr', np.mean(losses_psnr), epoch)
        writer.add_scalar('Dev_Loss_vif', np.mean(losses_vif), epoch)
        writer.add_scalar('Dev_Loss_ssim', np.mean(losses_ssim), epoch)
       
    return np.mean(losses_psnr), np.mean(losses_ssim), np.mean(losses_vif), time.perf_counter() - start
    #return np.mean(losses_vif), time.perf_counter() - start



def visualize(args, epoch, model, data_loader, writer):
    def save_image(image, tag):
        image -= image.min()
        image /= image.max()
        grid = torchvision.utils.make_grid(image, nrow=4, pad_value=1)
        writer.add_image(tag, grid, epoch)

    model.eval()
    with torch.no_grad():
        for iter, data in enumerate(tqdm(data_loader)):
            #input, target, coord, fname, slice = data
            input, kspace, target = data

            input = input.to(args.device)
            target = target.to(args.device)
            kspace = kspace.to(args.device)

            input = input.float()
            kspace = kspace.float()
            target = target.float()

            output = model(input, kspace)

            output = complex_abs(output.permute(0,2,3,1)) 
            target = complex_abs(target.permute(0,2,3,1))
            input  = complex_abs(input.permute(0,2,3,1))


            save_image(input, 'Input')
            save_image(target, 'Target')
            save_image(output, 'Reconstruction')
            save_image(torch.abs(target - output), 'Error')
            break

def save_model(exp_dir, epoch, model):

    out = torch.save(
        {
            #'epoch': epoch,
            #'args': args,
            'model': model.state_dict(),
            #'optimizer': optimizer.state_dict(),
            #'disc': disc.state_dict(),
            #'optimizerD': optimizerD.state_dict(),
            #'best_dev_mse': best_dev_mse,
            #'dev_mse': dev_mse,         
        },

        f=exp_dir / 'model_{}.pt'.format(epoch)
    )

    #if is_new_best_mse:
    #	shutil.copyfile(exp_dir / 'model.pt', exp_dir / 'best_model.pt')



def build_generator(args):
    #model = UNet(1,1).to(args.device)
    model = DnCnRefine(args,nc=3,mode='train').to(args.device)
    return model

def build_disc(args):
    netD = Discriminator(args)
    netD.to(args.device)
    optimizerD = optim.SGD(netD.parameters(),lr=5e-3)
    return netD, optimizerD


def load_model(checkpoint_file):
    checkpoint = torch.load(checkpoint_file)
    args = checkpoint['args']
    model = build_generator(args)

    if args.data_parallel:
        model = torch.nn.DataParallel(model)
    model.load_state_dict(checkpoint['model'])

    optimizer = build_optim(args, model.parameters())
    optimizer.load_state_dict(checkpoint['optimizer'])

    disc, optimizerD = build_disc(args)
    if args.data_parallel:
        disc = torch.nn.DataParallel(disc)    
    disc.load_state_dict(checkpoint['disc'])

    optimizerD.load_state_dict(checkpoint['optimizerD'])
    return checkpoint, model, optimizer, disc, optimizerD


def build_optim(args, params):
    optimizer = torch.optim.Adam(params, args.lr, weight_decay=args.weight_decay)
    return optimizer


def main(args):
    args.exp_dir.mkdir(parents=True, exist_ok=True)
    writer = SummaryWriter(log_dir=str(args.exp_dir / 'summary'))

    if args.resume:
        print('resuming model, batch_size', args.batch_size)
        checkpoint, model, optimizer, disc, optimizerD = load_model(args.checkpoint)
        args = checkpoint['args']
        best_dev_mse= checkpoint['best_dev_mse']
        start_epoch = checkpoint['epoch']
        del checkpoint

    else:
        model = build_generator(args)
        disc, optimizerD = build_disc(args)
        if args.data_parallel:
            model = torch.nn.DataParallel(model)
            disc = torch.nn.DataParallel(disc)
        optimizer = build_optim(args, model.parameters())
        best_dev_mse = 1e9
        start_epoch = 0

    train_loader, dev_loader, display_loader = create_data_loaders(args)
    scheduler = torch.optim.lr_scheduler.StepLR(optimizer, args.lr_step_size, args.lr_gamma)

    for epoch in range(start_epoch, args.num_epochs):
        is_new_best_mse = False
        scheduler.step(epoch)
        train_lossG, train_lossD, train_time = train_epoch(args, epoch, model, disc, train_loader, optimizer, optimizerD, writer)
        dev_psnr, dev_ssim, dev_vif, dev_time = evaluate(args, epoch, model, dev_loader, writer)
        #if dev_mse < best_dev_mse:
        #    is_new_best_mse = True
        #    best_dev_mse =  dev_mse

        visualize(args, epoch, model, display_loader, writer)
        #save_model(args, args.exp_dir, epoch, model, optimizer, disc, optimizerD, dev_mse, best_dev_mse, is_new_best_mse)
        save_model(args.exp_dir, epoch, model)
        logging.info(
            f'Epoch = [{epoch:4d}/{args.num_epochs:4d}] TrainLossG = {train_lossG:.4g} TrainLossD = {train_lossD:.4g} '
            f'DevPSNR = {dev_psnr:.4g} DevSSIM = {dev_ssim:.4g} DevVIF = {dev_vif:.4g}   TrainTime = {train_time:.4f}s DevTime = {dev_time:.4f}s',
        )
    writer.close()


def create_arg_parser():

    parser = argparse.ArgumentParser()
    parser.add_argument('--train-path', type=str, required=True, help='Path to training data')
    parser.add_argument('--val-path', type=str, required=True, help='Path to validation data')
    parser.add_argument('--acceleration', type=int, help='Acceleration factor for undersampled data')
    parser.add_argument('--batch-size', default=4, type=int,  help='Mini batch size')
    parser.add_argument('--num-epochs', type=int, default=150, help='Number of training epochs')
    parser.add_argument('--lr', type=float, default=0.001, help='Learning rate')
    parser.add_argument('--adv-weight', type=int, default=10, help='Weight for the adversarial loss function term in the loss function')
    parser.add_argument('--lr-step-size', type=int, default=40,
                        help='Period of learning rate decay')
    parser.add_argument('--lr-gamma', type=float, default=0.1,
                        help='Multiplicative factor of learning rate decay')
    parser.add_argument('--weight-decay', type=float, default=0.,
                        help='Strength of weight decay regularization')
    parser.add_argument('--data-parallel', action='store_true', 
                        help='If set, use multiple GPUs using data parallelism')
    parser.add_argument('--device', type=str, default='cuda',
                        help='Which device to train on. Set to "cuda" to use the GPU')
    parser.add_argument('--exp-dir', type=pathlib.Path, default='checkpoints',
                        help='Path where model and results should be saved')
    parser.add_argument('--resume', action='store_true',
                        help='If set, resume the training from a previous model checkpoint. '
                             '"--checkpoint" should be set with this')
    parser.add_argument('--checkpoint', type=str,
                        help='Path to an existing checkpoint. Used along with "--resume"')
    parser.add_argument('--seed', default=42, type=int, help='Seed for random number generators')

    parser.add_argument('--dataset_type',type=str,help='cardiac,kirby') 
    parser.add_argument('--usmask_path',type=str,help='us mask path')
    parser.add_argument('--dcrsnpath',type=str,help='dcrsn path')

    return parser


if __name__ == '__main__':
    args = create_arg_parser().parse_args()
    random.seed(args.seed)
    np.random.seed(args.seed)
    torch.manual_seed(args.seed)
    main(args)
