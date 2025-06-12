#!/bin/bash

# Helper function for notifications
notify() {
  echo "$2"
  if [[ -f /usr/local/emhttp/webGui/scripts/notify ]]; then
    /usr/local/emhttp/webGui/scripts/notify -i "$1" -s "$2" -d "$3" -m "$3"
  fi
}

# Define paths and datestamp
LOGDIR="/mnt/user/appdata/rsnapshot-docker/logs"
ARCHIVE="$LOGDIR/archive"
DATESTAMP=$(date "+%Y-%m-%d@%H%M")
LOGFILE="$LOGDIR/rsnapshot.$DATESTAMP.log"
DULOG="$LOGDIR/du.$DATESTAMP.log"
COPIEDLOG="$LOGDIR/files-copied.$DATESTAMP.log"

# Add timestamp to log file
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
echo "=== Backup started at $TIMESTAMP ===" >>"$LOGFILE"

# Run the backup (foreground to wait for completion)
docker exec rsnapshot-docker rsnapshot alpha

# Check for errors or warnings in log file
if [[ -f "$LOGFILE" ]]; then
  if grep -q "ERROR:" "$LOGFILE"; then
    LOGOUTPUT=$(grep -E "ERROR:|WARNING:" "$LOGFILE" | head -c 2048)
    notify "alert" "🛑 ALPHA backup complete with ERRORS:" "$LOGOUTPUT"
  elif grep -q "WARNING:" "$LOGFILE"; then
    LOGOUTPUT=$(grep "WARNING:" "$LOGFILE" | head -c 2048)
    notify "warning" "⚠️ ALPHA backup complete with warnings:" "$LOGOUTPUT"
  else
    notify "normal" "✅ ALPHA backup complete without error." "Have a nice day!"
  fi
else
  notify "alert" "🛑 ALPHA backup log missing!" "The rsnapshot log file could not be found."
fi

# Write out backup usage and free space
{
  echo "=== du report at $TIMESTAMP ==="
  docker exec rsnapshot-docker rsnapshot du
  echo
  echo "=== free space report ==="
  df -h /mnt/user
} >"$DULOG"

# Filter the log down to just copied items
if [[ -f "$LOGFILE" ]]; then
  grep "\] >" "$LOGFILE" > "$COPIEDLOG"
fi

# === ARCHIVING OLD LOGS ===
mkdir -p "$ARCHIVE"

find "$LOGDIR" -maxdepth 1 -type f -name "*.log" -mtime +15 | while read -r oldlog; do
  base=$(basename "$oldlog")
  mv "$oldlog" "$ARCHIVE/$base"
  gzip -f "$ARCHIVE/$base"
done
