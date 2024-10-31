# config file with variables
# time video was last accessed; if longer ago, file will be moved and processed

FILE_PREFIX="cricketvid"
FILE_EXTENSION="mp4"
FFMPEG_FLAGS="-loglevel error"

# interval during which process should sleep after starting it
SLEEP_POST_SETUP=3

# interval during which process should sleep after killing a process 
SLEEP_POST_KILL=3
WAIT_BEFORE_FETCH_FFMPEG_PID=1
VIDEO_PROG="ffmpeg"

# script that locates all the streams
STREAM_LOCATOR="locate_video_streams.sh"

# script that starts a single stream
SINGLE_STREAM_EXE="start_single_stream.sh"

# script that processes the video after they have been recorded and adds time stamps
POSTPROCESS="postprocess.sh"

# the main executable
RECORD_DAEMON="record_daemon.sh"

# duration of each movie in minutes
DURATION_MOVIE_MINUTES=30

# time interval that file has not been modified
# before postprocessing can begin
POSTPROCESS_FILE_MODIFIED_INTERVAL=10
FILE_POSTPROCESS_PREFIX="processed_"
