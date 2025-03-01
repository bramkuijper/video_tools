# `video_tools`: shell scripts to record multiple webcam streams to disk

## Requirements:
`ffmpeg` needs to be installed

## How to run:
Run the script `record_daemon.sh` which will keep running until stopped by `stop_record.sh`.
When `record_daemon.sh` is running it will write videos to disk, with the duration of a movie
given by the value of the variable `$DURATION_MOVIE_MINUTES` in `config.sh` (default 30 mins).

Once the video duration exceeds the duration in `$DURATION_MOVIE_MINUTES`, the video is stopped, written to disk and another video
is started.

## Postprocessing:
Burning in timestamps in videos that have stopped is done by the script `postprocess.sh`

## In `crontab`
Best to use this all in `crontab`. Here an example:
```
50 8 	* * 1	root    /home/bram/Downloads/video_tools/record_daemon.sh
10 18	* * 1	root    /home/bram/Downloads/video_tools/stop_record.sh
*/10 *  * * 1   root    /home/bram/Downloads/video_tools/postprocess.sh
```
