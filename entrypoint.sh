#!/bin/bash

# Create directories if they don't exist
mkdir -p /logs
mkdir -p /audio
mkdir -p /config

# Create config.sh and add the necessary variables
cat <<EOF > /config/config.sh
# Configuration file for audiologger.sh
# Set the URL of the audio stream to log
STREAM_URL="$STREAM_URL"
EOF

# Start the audiologger in the background
/usr/local/bin/audiologger.sh &
AUDIOLOGGER_PID=$!

# Setup signal handling to properly pass signals to child processes
trap 'kill -TERM $AUDIOLOGGER_PID; exit 0' TERM INT

# Wait for the audiologger process to finish or be terminated
wait $AUDIOLOGGER_PID