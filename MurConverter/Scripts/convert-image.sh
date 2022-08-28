#! /bin/bash -x

WORKING_DIR=$( pwd )

SOURCE_FILE=$1
SOURCE_FILE=$(echo "$SOURCE_FILE" | sed "s/%%%/ /g")

RESULT_FILE=$2
RESULT_FILE=$(echo "$RESULT_FILE" | sed "s/%%%/ /g")

RESULT_FORMAT=$3
IS_GRAYSCALE=$4
RESAMPLE_HEIGHT_VALUE=$5
RESAMPLE_WIDTH_VALUE=$6

# Should be always last argument!
QUALITY=$7

RESAMPLE_HEIGHT_OPTION=""
RESAMPLE_WIDTH_OPTION=""
RESAMPLE_HW_OPTION=""
if [ "${RESAMPLE_WIDTH_VALUE}" != "0" && "${RESAMPLE_HEIGHT_VALUE}" != "0"]; then
    RESAMPLE_HW_OPTION="--resampleHeightWidth $RESAMPLE_HEIGHT_VALUE $RESAMPLE_WIDTH_VALUE"

elif [ "${RESAMPLE_HEIGHT_VALUE}" != "0" ]; then
	RESAMPLE_HEIGHT_OPTION="--resampleHeight $RESAMPLE_HEIGHT_VALUE"

elif [ "${RESAMPLE_WIDTH_VALUE}" != "0" ]; then
	RESAMPLE_WIDTH_OPTION="--resampleWidth $RESAMPLE_WIDTH_VALUE"
fi

SOURCE_DIR="${SOURCE_FILE%/*}"
cd $SOURCE_DIR

SIPS_CMD="/usr/bin/sips"



if [ "${QUALITY}" != "0" ]; then
    $SIPS_CMD `echo $RESAMPLE_HW_OPTION` `echo $RESAMPLE_WIDTH_OPTION` `echo $RESAMPLE_HEIGHT_OPTION` -s format $RESULT_FORMAT -s formatOptions $QUALITY "${SOURCE_FILE}" --out "${RESULT_FILE}"
else
    $SIPS_CMD `echo $RESAMPLE_HW_OPTION` `echo $RESAMPLE_WIDTH_OPTION` `echo $RESAMPLE_HEIGHT_OPTION` -s format $RESULT_FORMAT "${SOURCE_FILE}" --out "${RESULT_FILE}"
fi

if $IS_GRAYSCALE; then
    $SIPS_CMD -M /System/Library/ColorSync/Profiles/Generic\ Gray\ Profile.icc relative "${RESULT_FILE}"
fi
#
#echo "1 - $SOURCE_FILE"
#echo "2 - $RESULT_FILE"
#echo "3 - $RESULT_FORMAT"
#echo "4 - $IS_GRAYSCALE"
#echo "5 - $RESAMPLE_HEIGHT_VALUE"
#echo "6 - $RESAMPLE_WIDTH_VALUE"
#echo "7 - $QUALITY"
