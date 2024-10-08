#!/usr/bin/env bash

# main recorder script
# what it does:
# 1. sees what streams are available
# 2. starts recording on each stream in a separate thread
# 3. checks every while whether thread is still working, otherwise restarts
# 3. after n minutes quits each stream and restarts the stream

# interval during which process should sleep
SLEEP_INTERVAL=3

# script that locates all the streams
STREAM_LOCATOR="locate_video_streams.sh"

# script that starts a single stream
SINGLE_STREAM_EXE="start_single_stream.sh"

# duration of each movie in minutes
DURATION_MOVIE_MINUTES=1

### function declarations

# function which checks whether the stream actually exists
# for example if usb cam has stopped working we might try to
# launch processes on it, but it won't work 
stream_exists () {
	ps -p $1 -o pid=
} # end stream_exists()


# start a video stream and return the pid
# this function assumes the stream exists
start_video () {
	stream_id=$1

	# check if an argument has actually been provided
	if [[ -z "${stream_id}" ]]; then
		return 0
	fi
	
	# find out whether a current process ID
	# is occupying our stream
	process_using_stream=`fuser "${stream_id}"`

	# if result of previous empty so no 
	# proces is running, start a video process here
	if [[ -z "${process_using_stream}" ]]; then
		bash "${SINGLE_STREAM_EXE}" ${stream_id} &
		new_pid=$! # here $! returns the process ID 
	fi
	
	echo $new_pid
	
	return 0
} # end start_video


# collect array of all the available video streams
streams=($(./$STREAM_LOCATOR))

# print message on how many video streams there are

# make empty associative array in which the keys are the 
# video directories and the values are the process ids
declare -A pids

# make empty associative array in which the keys are the 
# video directories and the values are the start times of
# the video
declare -A pid_start_times


# infinite loop waiting for SIGINT (Ctrl+C)
while true; do

	# go through video streams that are available 
	# and see whether they have a process ID
	# already associated with them
	for stream in "${streams[@]}"
	do
		# -z checks whether associative array entry for this stream 
		# is empty, meaning we need to make a new stream
		if [[ -z "${pids[$stream]}" ]]; then 

			pid=`start_video "${stream}"`

			if [[ -n $pid ]]; then
				pids["${stream}"]=$pid	# store process id
				pid_start_times["${stream}"]=`date +%s` # store time in seconds
			fi
		fi
	done

	sleep $SLEEP_INTERVAL

	# next bit of the loop is to check for times
	# that each process is running for. If this is longer 
	# than the desired number of minutes end the stream
	for stream in "${streams[@]}"
	do
		current_time=`date +%s`

		# vid lasted longer than duration in mins, cut it off
		if (( (${pid_start_times["${stream}"]}-$current_time) > $DURATION_MOVIE_MINUTES*60 )); then
			kill $pids["${stream}"]
		fi
	done
done
