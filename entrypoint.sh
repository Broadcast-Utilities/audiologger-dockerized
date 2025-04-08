#!/bin/sh

# Dynamically update config.sh from environment variables
if [ -n "$STREAM_URL" ]; then
    echo "STREAM_URL=$STREAM_URL" > /config.sh
fi
if [ -n "$STATION_NAME" ]; then
    echo "STATION_NAME=$STATION_NAME" >> /config.sh
fi



exec "$@"

bash /usr/local/bin/audiologger.sh

log_file="/log_$(date +%Y%m%d_%H%M%S).log"

echo
