MODEL='dagan'
DATASET_TYPE='cardiac'
BASE_PATH='/media/htic/NewVolume1/murali/MR_reconstruction'
USMASK_PATH=${BASE_PATH}'/Reconstruction-for-MRI/us_masks/'${DATASET_TYPE}

<<ACC_FACTOR_2x
ACC_FACTOR='2x'
CHECKPOINT=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/acc_'${ACC_FACTOR}'/'${MODEL}'/best_model.pt'
OUT_DIR=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/acc_'${ACC_FACTOR}'/'${MODEL}'/results'
BATCH_SIZE=1
DEVICE='cuda:1'
DATA_PATH=${BASE_PATH}'/datasets/'${DATASET_TYPE}'/validation/acc_'${ACC_FACTOR}
echo python valid.py --checkpoint ${CHECKPOINT} --out-dir ${OUT_DIR} --batch-size ${BATCH_SIZE} --device ${DEVICE} --data-path ${DATA_PATH} --acceleration_factor ${ACC_FACTOR} --dataset_type ${DATASET_TYPE} 
python valid.py --checkpoint ${CHECKPOINT} --out-dir ${OUT_DIR} --batch-size ${BATCH_SIZE} --device ${DEVICE} --data-path ${DATA_PATH} --acceleration_factor ${ACC_FACTOR} --dataset_type ${DATASET_TYPE} 
ACC_FACTOR_2x

<<ACC_FACTOR_3.3x
ACC_FACTOR='3_3x'
CHECKPOINT=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/acc_'${ACC_FACTOR}'/'${MODEL}'/best_model.pt'
OUT_DIR=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/acc_'${ACC_FACTOR}'/'${MODEL}'/results'
BATCH_SIZE=1
DEVICE='cuda:1'
DATA_PATH=${BASE_PATH}'/datasets/'${DATASET_TYPE}'/validation/acc_'${ACC_FACTOR}
echo python valid.py --checkpoint ${CHECKPOINT} --out-dir ${OUT_DIR} --batch-size ${BATCH_SIZE} --device ${DEVICE} --data-path ${DATA_PATH} --acceleration_factor ${ACC_FACTOR} --dataset_type ${DATASET_TYPE} 
python valid.py --checkpoint ${CHECKPOINT} --out-dir ${OUT_DIR} --batch-size ${BATCH_SIZE} --device ${DEVICE} --data-path ${DATA_PATH} --acceleration_factor ${ACC_FACTOR} --dataset_type ${DATASET_TYPE} 
ACC_FACTOR_3.3x


#<<ACC_FACTOR_5x
ACC_FACTOR='5x'
CHECKPOINT=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/acc_'${ACC_FACTOR}'/'${MODEL}'/best_model.pt'
OUT_DIR=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/acc_'${ACC_FACTOR}'/'${MODEL}'/results'
BATCH_SIZE=1
DEVICE='cuda:1'
DATA_PATH=${BASE_PATH}'/datasets/'${DATASET_TYPE}'/validation/acc_'${ACC_FACTOR}
echo python valid.py --checkpoint ${CHECKPOINT} --out-dir ${OUT_DIR} --batch-size ${BATCH_SIZE} --device ${DEVICE} --data-path ${DATA_PATH} --acceleration_factor ${ACC_FACTOR} --dataset_type ${DATASET_TYPE} 
python valid.py --checkpoint ${CHECKPOINT} --out-dir ${OUT_DIR} --batch-size ${BATCH_SIZE} --device ${DEVICE} --data-path ${DATA_PATH} --acceleration_factor ${ACC_FACTOR} --dataset_type ${DATASET_TYPE} 
#ACC_FACTOR_5x

<<ACC_FACTOR_8x
ACC_FACTOR='8x'
CHECKPOINT=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/acc_'${ACC_FACTOR}'/'${MODEL}'/best_model.pt'
OUT_DIR=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/acc_'${ACC_FACTOR}'/'${MODEL}'/results'
BATCH_SIZE=1
DEVICE='cuda:1'
DATA_PATH=${BASE_PATH}'/datasets/'${DATASET_TYPE}'/validation/acc_'${ACC_FACTOR}
echo python valid.py --checkpoint ${CHECKPOINT} --out-dir ${OUT_DIR} --batch-size ${BATCH_SIZE} --device ${DEVICE} --data-path ${DATA_PATH} --acceleration_factor ${ACC_FACTOR} --dataset_type ${DATASET_TYPE} 
python valid.py --checkpoint ${CHECKPOINT} --out-dir ${OUT_DIR} --batch-size ${BATCH_SIZE} --device ${DEVICE} --data-path ${DATA_PATH} --acceleration_factor ${ACC_FACTOR} --dataset_type ${DATASET_TYPE} 
ACC_FACTOR_8x


