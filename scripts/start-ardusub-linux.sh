#!/bin/bash
# Check if navigator is connected and starts ardusub linux
ARDUSUB_FOLDER=$COMPANION_DIR/ardusub

$COMPANION_DIR/scripts/detect-navigator.sh
NAVIGATOR_VERSION=$?

if [ NAVIGATOR_VERSION == 0 ]; then
    echo "No navigator board detected."
    exit 1
fi

echo "Navigator board detected!"

# Kill ardusub-socat and check if /dev/autopilot exist
screen -X -S ardusub-socat quit

if [ -f "/dev/autopilot" ]; then
    echo "/dev/autpilot exists, check if pixhawk is connected and restart companion."
    exit 1
fi

echo "Create socat bridge between /dev/navigator and /dev/autopilot."
sudo -H -u pi screen -dm -S ardusub-socat \
    sudo socat \
    PTY,perm=0666,link=/dev/autopilot \
    PTY,perm=0666,link=/dev/navigator

echo "Start ardusub linux."
screen -X -S ardusub-linux quit
sudo -H -u pi screen -dm -S ardusub-linux \
    sudo $ARDUSUB_FOLDER/ardusub \
    -A /dev/navigator \
    --log-directory $ARDUSUB_FOLDER/logs/ \
    --storage-directory $ARDUSUB_FOLDER/storage/