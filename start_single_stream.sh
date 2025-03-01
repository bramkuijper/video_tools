#!/usr/bin/env bash

### some scripts to get current location of bash script
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
	SOURCE=$(readlink "$SOURCE")
	[[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

CONFIG="config.sh"

. ${DIR}/${CONFIG}




# script that records video from a single webcam
# how to run it: 
# ./record_video.sh number file


# collect array of all the available video streams
streams=($(${DIR}/${STREAM_LOCATOR}))

current_date=`date`

if [[ -z "${1}" ]]; then
	logger "${current_date}: Error in start_single_stream.sh: no video device provided."
	exit 1
fi

# see whether requested stream exists
# otherwise throw error and exit with error code
if [[ ! " ${streams[*]} " =~ [[:space:]]${1}[[:space:]] ]]; then
	logger "${current_date}: Error in start_single_stream.sh: the video device \"${1}\" does not exist, please provide the full path"
	exit 1
fi

# check whether device is busy
if [[ -n `fuser "${1}"` ]]; then
	logger "${current_date}: device ${1} is busy"
	exit 1
fi

vid_basename=`basename ${1}`

out_file="$FILE_PREFIX"_"$(date '+%Y_%m_%d_%H%M%S_%N')"_${vid_basename}.${FILE_EXTENSION}

$VIDEO_PROG -loglevel error -f video4linux2 -framerate 30 -video_size 1920x1080 -input_format mjpeg -i "${1}" "${out_file}"
