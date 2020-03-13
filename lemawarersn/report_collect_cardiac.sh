
MODEL='dc-rsn-feat-usereconfile'

BASE_PATH='/media/htic/NewVolume1/murali/MR_reconstruction'
DATASET_TYPE='cardiac'
MASK_TYPE='cartesian'

echo ${MODEL}
echo ${DATASET_TYPE}
echo ${MASK_TYPE}


#<<ACC_FACTOR_4x
ACC_FACTOR='4x'
REPORT_PATH=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/'${MASK_TYPE}'/acc_'${ACC_FACTOR}'/rsnlossfunctions/'${MODEL}'/report.txt'
echo ${REPORT_PATH}
echo ${ACC_FACTOR}
cat ${REPORT_PATH}
echo "\n"
#ACC_FACTOR_4x


#<<ACC_FACTOR_5x
ACC_FACTOR='5x'
REPORT_PATH=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/'${MASK_TYPE}'/acc_'${ACC_FACTOR}'/rsnlossfunctions/'${MODEL}'/report.txt'
echo ${REPORT_PATH}
echo ${ACC_FACTOR}
cat ${REPORT_PATH}
echo "\n"
#ACC_FACTOR_5x


#<<ACC_FACTOR_8x
ACC_FACTOR='8x'
REPORT_PATH=${BASE_PATH}'/experiments/'${DATASET_TYPE}'/'${MASK_TYPE}'/acc_'${ACC_FACTOR}'/rsnlossfunctions/'${MODEL}'/report.txt'
echo ${REPORT_PATH}
echo ${ACC_FACTOR}
cat ${REPORT_PATH}
echo "\n"
#ACC_FACTOR_8x



