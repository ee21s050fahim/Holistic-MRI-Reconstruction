
MODEL='deep-cascade-rsn1-assist'
#MODEL='deep-cascade-rsn1'
#MODEL='zf'
BASE_PATH='/data/balamurali'
DATASET_TYPE='brats'


echo ${MODEL}
echo ${DATASET_TYPE}

#<<ACC_FACTOR_5x
ACC_FACTOR='5x'
REPORT_PATH=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/'${MODEL}'/report.txt'
echo ${ACC_FACTOR}
cat ${REPORT_PATH}
echo "\n"
#ACC_FACTOR_5x

MODEL='unet'
#MODEL='zf'
DATASET_TYPE='brats'


echo ${MODEL}
echo ${DATASET_TYPE}

#<<ACC_FACTOR_5x
ACC_FACTOR='5x'
REPORT_PATH=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/'${MODEL}'/report.txt'
echo ${ACC_FACTOR}
cat ${REPORT_PATH}
echo "\n"
#ACC_FACTOR_5x


