#!/usr/bin/env bash

# this scripts stops the video recording
kill $(ps ax | grep record_deamon.sh | awk -F' ' '{ print $1 }')
