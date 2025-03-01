#!/usr/bin/env bash

# script that burns in timestamps of videos that have been finished.
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


### first thing we need to do is find all video files that have not been processed yet
### and that are older than 10 minutes
all_unprocessed_files=`find . -maxdepth 1 -mmin +$POSTPROCESS_FILE_MODIFIED_INTERVAL -iname "${FILE_PREFIX}*"`

for preprocess_vid in ${all_unprocessed_files[@]}; do

    # extract folders
    dirname_vid=`dirname ${preprocess_vid}`;
    basename_vid=`basename ${preprocess_vid}`;

    new_file_name="${dirname_vid}/$FILE_POSTPROCESS_PREFIX${basename_vid}"
    
    # ok file does not exist
    if [ ! -f "${new_file_name}" ]; 
    then
        # ok let's preprocess this file
        # get time of vid creation in seconds since epoch time
        creation_time=`stat -c %Y "${preprocess_vid}"`

        ffmpeg -y -i "${preprocess_vid}" -vf "drawtext=fontsize=20:fontcolor=white:borderw=3:bordercolor=black:text='%{pts\:gmtime\:${creation_time}\:\%A, %d, %B %Y %H\\\\\:%M\\\\\:%S}'" -preset ultrafast -f mp4 "${new_file_name}"
    fi
done

