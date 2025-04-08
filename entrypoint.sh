#!/bin/sh


# Create config.sh and add the necessary variables
cat <<EOF > /config.sh
# Configuration file for audiologger.sh
# Set the URL of the audio stream to log
STREAM_URL="$STREAM_URL"
EOF


# Create directories if they don't exist
mkdir -p /logs
mkdir -p /audio
mkdir -p /config
# Copy the config file to the config folder
cp /config.sh /config/config.sh


exec "$@"

bash /usr/local/bin/audiologger.sh


LOG_FILE="/logs/continuous.log"

# Wait till logfile is created
while [ ! -f "$LOG_FILE" ]; do
    sleep 1
done

# Tail the log file to see the output
tail -f "LOG_FILE"



