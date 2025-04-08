#!/bin/sh

# Create directories if they don't exist
mkdir -p /logs
mkdir -p /audio
mkdir -p /config

# Create config.sh and add the necessary variables
cat <<EOF > /config/config.sh
# Configuration file for audiologger.sh
# Set the URL of the audio stream to log
STREAM_URL="$STREAM_URL"
LOG_DIR="/logs"
AUDIO_DIR="/audio"
EOF

# Start the audiologger in the background
bash /usr/local/bin/audiologger.sh &

# Wait a moment for the log file to be created
sleep 2

# Tail the log file to see the output
LOG_FILE="/logs/continuous.log"
if [ -f "$LOG_FILE" ]; then
  echo "Audio logger started. Showing log output:"
  exec tail -f "$LOG_FILE"
else
  echo "ERROR: Log file was not created. Check for errors in the audiologger.sh script."
  exit 1
fi