#!/usr/bin/env bash

echo "this runs"

# script that records video from a single webcam
# how to run it: 
# ./record_video.sh number file

FILE_PREFIX=cricketvid
FILE_EXTENSION=mp4
FFMPEG_FLAGS="-loglevel error"

# collect array of all the available video streams
streams=($(./locate_video_streams.sh))

if [[ -z "${1}" ]]; then
	echo "Error in start_single_stream.sh: no video device provided."
	exit 1
fi

# see whether requested stream exists
# otherwise throw error and exit with error code
if [[ ! " ${streams[*]} " =~ [[:space:]]${1}[[:space:]] ]]; then
	echo "Error in start_single_stream.sh: the video device \"${1}\" does not exist, please provide the full path"
	exit 1
fi

vid_basename=`basename ${1}`

out_file="$FILE_PREFIX"_"$(date '+%Y_%m_%d_%H%M%S_%N')"_${vid_basename}.${FILE_EXTENSION}

echo "${FFMPEG_FLAGS}"

ffmpeg $FFMPEG_FLAGS -f video4linux2 -framerate 30 -video_size 1920x1080 -input_format mjpeg -i "${1}" "${out_file}"
