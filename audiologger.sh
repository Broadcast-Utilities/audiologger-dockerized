#!/usr/bin/env bash
# This script is used to log audio data from livestreams and save it to a file.
# It is designed to be run in a loop, and will continue to log audio until stopped.
# It uses the `ffmpeg` command to capture audio from the default input device and save it to a file.

set -euo pipefail

CONFIG_FILE="config.sh"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Configuration file $CONFIG_FILE not found!"
    exit 1
fi
source "$CONFIG_FILE"

# Check if required commands are available
for cmd in ffmpeg; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Command $cmd not found. Please install it."
        exit 1
    fi
done

# Check if directories exist, create them if not
if [[ ! -d "$LOG_DIR" ]]; then
    mkdir -p "$LOG_DIR"
fi
if [[ ! -d "$AUDIO_DIR" ]]; then
    mkdir -p "$AUDIO_DIR"
fi



# Function to get formatted timestamps for filenames
get_timestamp() {
  date +"%Y%m%d_%H%M%S"
}

# Function to log audio for a specified duration
log_audio() {
  local start_time=$(get_timestamp)
  local audio_file="${AUDIO_DIR}/audio_${start_time}.mp3"
  local log_file="${LOG_DIR}/log_${start_time}.log"
  
  echo "Logging audio from $STREAM_URL to $log_file and $audio_file"
  # Use ffmpeg to capture audio from the stream with time limit
  ffmpeg -i "$STREAM_URL" -codec:a libmp3lame -ar 48000 -b:a 192k -ac 2 -t "$1" "$audio_file" &> "$log_file"
}

# Main loop to create hourly recordings
hourly_recordings() {
  while true; do
    # Calculate seconds until the next hour
    local current_minute=$(date +%M)
    local current_second=$(date +%S)
    local seconds_to_next_hour=$(( (60 - current_minute) * 60 - current_second ))
    
    if [ $seconds_to_next_hour -eq 3600 ]; then
      # If we're exactly at the top of the hour, record for a full hour
      log_audio 3600
    else
      # Otherwise record until the top of the next hour
      log_audio $seconds_to_next_hour
    fi
  done
}

# Start the hourly recording process
hourly_recordings