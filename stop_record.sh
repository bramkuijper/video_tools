#!/usr/bin/env bash
# this scripts stops the video recording

daemon_process=`ps ax | grep "[r]ecord_daemon.sh" | awk -F' ' '{ print $1 }'`
start_single=`ps ax | grep "[s]start_single_stream.sh" | awk -F' ' '{ print $1 }'`
ffmpeg_process=`ps ax | grep "[f]fmpeg" | awk -F' ' '{ print $1 }'`

the_date=`date`
logger "${the_date}: lets kill processes"

if [[ -n ${daemon_process} ]]; then
	the_date=`date`
	logger "${the_date}: killing daemon process ${daemon_process}."
	kill ${daemon_process}
fi

if [[ -n ${start_single} ]]; then
	the_date=`date`
	logger "${the_date}: killing start_single_stream.sh, processes ${start_single}."
	kill ${start_single}
fi

if [[ -n ${ffmpeg_process} ]]; then
	the_date=`date`
	logger "${the_date}: killing ffmpeg, processes ${ffmpeg_process}."
	kill ${ffmpeg_process}
fi
