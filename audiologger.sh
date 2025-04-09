#!/bin/bash

# Set up variables
LOG_DIR="/logs"
AUDIO_DIR="/audio"
CONFIG_FILE="/config/config.sh"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Setup continuous log file
CONTINUOUS_LOG="${LOG_DIR}/continuous.log"
touch "$CONTINUOUS_LOG"

# Function to log messages to both console and continuous log file
log_message() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local message="$timestamp - $1"
  echo "$message"
  echo "$message" >> "$CONTINUOUS_LOG"
}

# Function to get formatted date and hour for filenames
get_hour_timestamp() {
  date +"%Y%m%d_%H"
}

# Function to log audio for a specified duration
log_audio() {
  local start_time=$(get_hour_timestamp)
  local audio_file="${AUDIO_DIR}/audio_${start_time}.mp3"
  local log_file="${LOG_DIR}/log_${start_time}.log"
  
  log_message "Starting new recording session (${1}s duration)"
  log_message "Logging audio from $STREAM_URL to $audio_file"
  
  # Use ffmpeg to capture audio from the stream with time limit
  local max_retries=3
  local retry_count=0
  local success=false
  
  while [ $retry_count -lt $max_retries ] && [ "$success" = false ]; do
    ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 5 -i "$STREAM_URL" -codec:a libmp3lame -ar 48000 -b:a 192k -ac 2 -t "$1" "$audio_file" &> "$log_file"
    if [ $? -eq 0 ]; then
      log_message "Recording completed successfully: $audio_file"
      success=true
    else
      retry_count=$((retry_count + 1))
      if [ $retry_count -lt $max_retries ]; then
        log_message "WARNING: Recording failed. Retrying ($retry_count/$max_retries)..."
        sleep 5  # Wait 5 seconds before retrying
      else
        log_message "ERROR: Recording failed for session starting at $start_time after $max_retries attempts"
        log_message "--- ffmpeg error log start ---"
        cat "$log_file" >> "$CONTINUOUS_LOG"
        log_message "--- ffmpeg error log end ---"
      fi
    fi
  done
  
  # If we're still failing after retries, wait a bit before next attempt
  if [ "$success" = false ]; then
    log_message "Waiting 30 seconds before next recording attempt"
    sleep 30
  fi
}

# Function to sleep until the next hour
wait_until_next_hour() {
  # Calculate seconds until the next hour
  local current_minute=$(date +%-M)
  local current_second=$(date +%-S)
  local seconds_to_wait=$(( (60 - current_minute) * 60 - current_second ))
  
  if [ $seconds_to_wait -eq 0 ]; then
    # Already at the top of the hour, so return immediately
    return
  fi
  
  log_message "Waiting for ${seconds_to_wait} seconds until next hour"
  sleep $seconds_to_wait
}

# Function to perform hourly recordings
hourly_recordings() {
  log_message "Starting hourly recording process"
  
  # Always start by aligning to the top of the hour
  wait_until_next_hour
  
  while true; do
    # Get the current hour (for logging)
    local current_hour=$(date +%H)
    log_message "Starting recording for hour: $current_hour:00"
    
    # Record for exactly one hour (3600 seconds)
    log_audio 3600
    
    # Wait until the next hour before starting the next recording
    # This ensures we always start at the top of the hour
    wait_until_next_hour
  done
}

# Main execution - run the script
log_message "Audio logger script starting"
log_message "Using stream URL: $STREAM_URL"
log_message "Log directory: $LOG_DIR"
log_message "Audio directory: $AUDIO_DIR"
hourly_recordings