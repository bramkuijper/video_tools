#!/usr/bin/env bash

# thanks to https://heemayl.net/posts/find-the-actual-webcam-device-dev-videoX-in-linux/

for device in /dev/video*; do
	udevadm info "$device" | { grep -q 'CAPABILITIES=.*:capture:' && echo "$device" ;}
done

