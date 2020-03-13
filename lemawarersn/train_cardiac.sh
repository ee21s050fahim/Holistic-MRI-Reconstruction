MODEL='dc-rsn-feat-usereconfile'
BASE_PATH='/media/htic/NewVolume1/murali/MR_reconstruction'
DATASET_TYPE='cardiac'
MASK_TYPE='cartesian'

<<ACC_FACTOR_4x
BATCH_SIZE=4
NUM_EPOCHS=150
DEVICE='cuda:1'
ACC_FACTOR='4x'

EXP_DIR=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/'${MASK_TYPE}'/acc_'${ACC_FACTOR}'/rsnlossfunctions/'${MODEL}
TRAIN_PATH=${BASE_PATH}'/datasets/'${DATASET_TYPE}'/'${MASK_TYPE}'/train/acc_'${ACC_FACTOR}
VALIDATION_PATH=${BASE_PATH}'/datasets/'${DATASET_TYPE}'/'${MASK_TYPE}'/validation/acc_'${ACC_FACTOR}

USMASK_PATH=${BASE_PATH}'/Reconstruction-for-MRI/us_masks/'${DATASET_TYPE}'/'${MASK_TYPE}
SEG_UNET_PATH=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/acc_5x/rsnlossfunctions/unetLEM/best_model.pt' # check this with sriprabha
#DNCN_MODEL_PATH=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/'${MASK_TYPE}'/acc_'${ACC_FACTOR}'/ablative-dA-fastMRIUNet-wang_etal-three-channels/best_model.pt'
DNCN_MODEL_PATH=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/'${MASK_TYPE}'/acc_'${ACC_FACTOR}'/ablative-dA-fastMRIUNet-wang_etal-three-channels/'

#python train.py --batch-size ${BATCH_SIZE} --num-epochs ${NUM_EPOCHS} --device ${DEVICE} --exp-dir ${EXP_DIR} --train-path ${TRAIN_PATH} --validation-path ${VALIDATION_PATH} --acceleration_factor ${ACC_FACTOR} --dataset_type ${DATASET_TYPE} --usmask_path ${USMASK_PATH} --unet_model_path ${UNET_MODEL_PATH} --dautomap_model_path ${dAUTOMAP_MODEL_PATH} --seg_unet_path ${SEG_UNET_PATH} --dncn_model_path ${DNCN_MODEL_PATH} --srcnnlike_model_path ${SRCNN_MODEL_PATH}
python train.py --batch-size ${BATCH_SIZE} --num-epochs ${NUM_EPOCHS} --device ${DEVICE} --exp-dir ${EXP_DIR} --train-path ${TRAIN_PATH} --validation-path ${VALIDATION_PATH} --acceleration_factor ${ACC_FACTOR} --dataset_type ${DATASET_TYPE} --usmask_path ${USMASK_PATH} --seg_unet_path ${SEG_UNET_PATH} --dncn_model_path ${DNCN_MODEL_PATH} 
ACC_FACTOR_4x


<<ACC_FACTOR_5x
BATCH_SIZE=4
NUM_EPOCHS=150
DEVICE='cuda:1'
ACC_FACTOR='5x'

EXP_DIR=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/'${MASK_TYPE}'/acc_'${ACC_FACTOR}'/rsnlossfunctions/'${MODEL}
TRAIN_PATH=${BASE_PATH}'/datasets/'${DATASET_TYPE}'/'${MASK_TYPE}'/train/acc_'${ACC_FACTOR}
VALIDATION_PATH=${BASE_PATH}'/datasets/'${DATASET_TYPE}'/'${MASK_TYPE}'/validation/acc_'${ACC_FACTOR}

USMASK_PATH=${BASE_PATH}'/Reconstruction-for-MRI/us_masks/'${DATASET_TYPE}'/'${MASK_TYPE}
SEG_UNET_PATH=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/acc_'${ACC_FACTOR}'/rsnlossfunctions/unetLEM/best_model.pt'
#DNCN_MODEL_PATH=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/'${MASK_TYPE}'/acc_'${ACC_FACTOR}'/ablative-dA-fastMRIUNet-wang_etal-three-channels/best_model.pt'
DNCN_MODEL_PATH=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/'${MASK_TYPE}'/acc_'${ACC_FACTOR}'/ablative-dA-fastMRIUNet-wang_etal-three-channels/'

#python train.py --batch-size ${BATCH_SIZE} --num-epochs ${NUM_EPOCHS} --device ${DEVICE} --exp-dir ${EXP_DIR} --train-path ${TRAIN_PATH} --validation-path ${VALIDATION_PATH} --acceleration_factor ${ACC_FACTOR} --dataset_type ${DATASET_TYPE} --usmask_path ${USMASK_PATH} --unet_model_path ${UNET_MODEL_PATH} --dautomap_model_path ${dAUTOMAP_MODEL_PATH} --seg_unet_path ${SEG_UNET_PATH} --dncn_model_path ${DNCN_MODEL_PATH} --srcnnlike_model_path ${SRCNN_MODEL_PATH}
python train.py --batch-size ${BATCH_SIZE} --num-epochs ${NUM_EPOCHS} --device ${DEVICE} --exp-dir ${EXP_DIR} --train-path ${TRAIN_PATH} --validation-path ${VALIDATION_PATH} --acceleration_factor ${ACC_FACTOR} --dataset_type ${DATASET_TYPE} --usmask_path ${USMASK_PATH} --seg_unet_path ${SEG_UNET_PATH} --dncn_model_path ${DNCN_MODEL_PATH} 
ACC_FACTOR_5x

#<<ACC_FACTOR_8x
BATCH_SIZE=3
NUM_EPOCHS=150
DEVICE='cuda:0'
ACC_FACTOR='8x'

EXP_DIR=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/'${MASK_TYPE}'/acc_'${ACC_FACTOR}'/rsnlossfunctions/'${MODEL}
TRAIN_PATH=${BASE_PATH}'/datasets/'${DATASET_TYPE}'/'${MASK_TYPE}'/train/acc_'${ACC_FACTOR}
VALIDATION_PATH=${BASE_PATH}'/datasets/'${DATASET_TYPE}'/'${MASK_TYPE}'/validation/acc_'${ACC_FACTOR}

USMASK_PATH=${BASE_PATH}'/Reconstruction-for-MRI/us_masks/'${DATASET_TYPE}'/'${MASK_TYPE}
SEG_UNET_PATH=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/acc_5x/rsnlossfunctions/unetLEM/best_model.pt' # check this with sriprabha
#DNCN_MODEL_PATH=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/'${MASK_TYPE}'/acc_'${ACC_FACTOR}'/ablative-dA-fastMRIUNet-wang_etal-three-channels/best_model.pt'
DNCN_MODEL_PATH=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/'${MASK_TYPE}'/acc_'${ACC_FACTOR}'/ablative-dA-fastMRIUNet-wang_etal-three-channels/'

#python train.py --batch-size ${BATCH_SIZE} --num-epochs ${NUM_EPOCHS} --device ${DEVICE} --exp-dir ${EXP_DIR} --train-path ${TRAIN_PATH} --validation-path ${VALIDATION_PATH} --acceleration_factor ${ACC_FACTOR} --dataset_type ${DATASET_TYPE} --usmask_path ${USMASK_PATH} --unet_model_path ${UNET_MODEL_PATH} --dautomap_model_path ${dAUTOMAP_MODEL_PATH} --seg_unet_path ${SEG_UNET_PATH} --dncn_model_path ${DNCN_MODEL_PATH} --srcnnlike_model_path ${SRCNN_MODEL_PATH}
python train.py --batch-size ${BATCH_SIZE} --num-epochs ${NUM_EPOCHS} --device ${DEVICE} --exp-dir ${EXP_DIR} --train-path ${TRAIN_PATH} --validation-path ${VALIDATION_PATH} --acceleration_factor ${ACC_FACTOR} --dataset_type ${DATASET_TYPE} --usmask_path ${USMASK_PATH} --seg_unet_path ${SEG_UNET_PATH} --dncn_model_path ${DNCN_MODEL_PATH} 
#ACC_FACTOR_8x



