#!/usr/bin/env bash

# main recorder script
# what it does:
# 1. sees what streams are available
# 2. starts recording on each stream in a separate thread
# 3. checks every while whether thread is still working, otherwise restarts
# 3. after n minutes quits each stream and restarts the stream

CONFIG_FILE="config.sh"

### get current location of bash script
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
	SOURCE=$(readlink "$SOURCE")
	[[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )


# read in the configuration file
. $DIR/$CONFIG


if [[ -z $1 ]]; then
	echo "Error in ${0}: please provide duration of movie in minutes"
	exit 1
fi



### function declarations

# function which checks whether the stream actually exists
# for example if usb cam has stopped working we might try to
# launch processes on it, but it won't work 
process_exists () {
	# echo "$@" 1>&2
	if [[ -n ${1} ]]; then
		ps -p $1 -o pid=
	fi
} # end process_exists()

# get the process id of ffmpeg and 
# try to kill that
get_ffmpeg_id () {
	# echo "$@" 1>&2

	if [[ -n ${1} ]]; then
		ps ax | grep ${1} | grep "$VIDEO_PROG" | awk -F' ' '{ print $1 }'
	fi
}


# collect array of all the available video streams
streams=($(${DIR}/${STREAM_LOCATOR}))

# print message on how many video streams there are

# make empty associative array in which the keys are the 
# video directories and the values are the process ids
declare -A pids

# make empty associative array in which the keys are the 
# video directories and the values are the start times of
# the video
declare -A pid_start_times


# function that cleans up all processes 
# if we receive an interrupt
cleanup () {

	# for some weird reason killing one stream
	# kills all of them
#	for stream in "${streams[@]}"
#	do
#		echo "killing pid ${pids[${stream}]}"
#		kill "${pids[${stream}]}"
#
#		sleep $WAIT_BEFORE_FETCH_FFMPEG_PID
#	done

	echo "really not sure why it is not acting on cleanup"

	# this is not great, as one gets 'Immediate exit requested'
	# errors in ffmpeg, but it is the only way to safely kill processes
	# it seems
	killall --user $USER --ignore-case --signal SIGTERM "$VIDEO_PROG"
	exit 1
}

# make traps that capture kill signals so that we can kill all 
# child processes that use ffmpeg
trap cleanup SIGINT
trap cleanup SIGTERM


# infinite loop waiting for SIGINT (Ctrl+C)
while true; do

	# go through video streams that are available 
	# and see whether they have a process ID
	# already associated with them
	for stream in "${streams[@]}"
	do
		# -z checks whether associative array entry for this stream 
		# is empty, meaning we need to make a new stream
		if [[ -z "${pids[$stream]}" || -z `process_exists "${pids[$stream]}"` ]]; then 

			# echo "starting video on stream ${stream}"
			
			bash "${DIR}/${SINGLE_STREAM_EXE}" "${stream}" &

			# wait until ffmpeg is indeed running
			sleep $WAIT_BEFORE_FETCH_FFMPEG_PID

			the_fpid=`get_ffmpeg_id ${stream}`

			# if the process id still exists
			# it means it did not prematurely end in error
			# store the thing
			if [[ -n $the_fpid && -n `process_exists "${the_fpid}"` ]]; then
				pids[${stream}]=$the_fpid	# store process id
				pid_start_times[${stream}]=`date +%s` # store time in seconds
			fi
		
			# echo "stream with pid ${the_fpid} on ${stream} started."
		fi
	done

	# echo "zzz"
	sleep $SLEEP_POST_SETUP

	# next bit of the loop is to check for times
	# that each process is running for. If this is longer 
	# than the desired number of minutes end the stream
	for stream in "${streams[@]}"
	do
		# first check whether process actually still exists
		# otherwise we don't need to do all this
		if [[ -z `process_exists "${pids[${stream}]}"` ]]; then
			unset 'pids[$stream]'
		else # ok process is still existing check whether we need to kill it

			current_time=`date +%s`

			# vid lasted longer than duration in mins, cut it off
			if (( ($current_time - ${pid_start_times[${stream}]}) > $DURATION_MOVIE_MINUTES*60 )); then

				# echo "killing pid ${pids[${stream}]}"
				kill "${pids[${stream}]}"
			
				sleep $WAIT_BEFORE_FETCH_FFMPEG_PID

				# check whether process still exists
				if [[ -z `process_exists "${pids[${stream}]}"` ]]; then
					unset 'pids[$stream]'
				else
					echo "even after killing process ${pids[${stream}]} still exists."
				fi


				# wild, just wild how to unset stuff in an associative array in bash
				# https://stackoverflow.com/questions/39172400/unseting-a-value-in-an-associative-bash-array-when-the-key-contains-a-quote
			fi
		fi
	done
	
	sleep $SLEEP_POST_KILL
done
