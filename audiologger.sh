# Function to log audio for a specified duration
log_audio() {
  local start_time=$(get_timestamp)
  local audio_file="${AUDIO_DIR}/audio_${start_time}.mp3"
  local log_file="${LOG_DIR}/log_${start_time}.log"
  
  log_message "Starting new recording session (${1}s duration)"
  log_message "Logging audio from $STREAM_URL to $audio_file"
  
  # Use ffmpeg to capture audio from the stream with time limit
  local max_retries=3
  local retry_count=0
  local success=false
  
  while [ $retry_count -lt $max_retries ] && [ "$success" = false ]; do
    # Within the log_audio function:
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