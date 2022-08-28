#! /bin/bash

IMAGEMAGIC_CMD=$1

SOURCE_FILE=$2
SOURCE_FILE=$(echo "$SOURCE_FILE" | sed "s/%%%/ /g")

RESULT_FILE=$3
RESULT_FILE=$(echo "$RESULT_FILE" | sed "s/%%%/ /g")

RESULT_FORMAT=$4
IS_GRAYSCALE=$5
IS_BLURRED=$6
BLUR_VALUE=$7
RESAMPLE_HEIGHT_VALUE=$8
RESAMPLE_WIDTH_VALUE=$9

# Should be always last argument!
QUALITY=$10

RESAMPLE_HEIGHT_OPTION=""
RESAMPLE_WIDTH_OPTION=""
RESAMPLE_HW_OPTION=""
if [ "${RESAMPLE_WIDTH_VALUE}" != "0" ] && [ "${RESAMPLE_HEIGHT_VALUE}" != "0" ]; then
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

if $IS_BLURRED; then
    RESULT_FILES_DIR="${RESULT_FILE%/*}"
    FILENAME=$(basename -- "$RESULT_FILE")
    EXTENSION="${FILENAME##*.}"
    FILENAME="${FILENAME%.*}"
    $IMAGEMAGIC_CMD "${RESULT_FILE}" -filter Gaussian -define filter:sigma=$BLUR_VALUE -resize 100% "${RESULT_FILES_DIR}/${FILENAME}-blur.${EXTENSION}"
fi

echo "2 - $SOURCE_FILE"
echo "3 - $RESULT_FILE"
echo "4 - $RESULT_FORMAT"
echo "5 - $IS_GRAYSCALE"
echo "6 - $IS_BLURRED"
echo "7 - $BLUR_VALUE"
echo "8 - $RESAMPLE_HEIGHT_VALUE"
echo "9 - $RESAMPLE_WIDTH_VALUE"
echo "10 - $QUALITY"
