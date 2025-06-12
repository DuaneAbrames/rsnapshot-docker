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
RAWLOG="$LOGDIR/rsnapshot.log"  # Created by backup tool
RENAMEDLOG="$LOGDIR/rsnapshot.$DATESTAMP.log"
DULOG="$LOGDIR/du.$DATESTAMP.log"
COPIEDLOG="$LOGDIR/files-copied.$DATESTAMP.log"

# Ensure log directory exists
mkdir -p "$LOGDIR"

# Add timestamp entry to raw log (optional, in case backup doesn't do it)
echo "=== Backup started at $(date "+%Y-%m-%d %H:%M:%S") ===" >>"$RAWLOG"

# Run the backup (foreground to wait for completion)
docker exec rsnapshot-docker rsnapshot alpha

# Rename the raw log after the backup finishes
if [[ -f "$RAWLOG" ]]; then
  mv "$RAWLOG" "$RENAMEDLOG"
else
  notify "alert" "🛑 ALPHA backup log missing!" "The rsnapshot log file could not be found."
  exit 1
fi

# Check for errors or warnings in renamed log
if grep -q "ERROR:" "$RENAMEDLOG"; then
  LOGOUTPUT=$(grep -E "ERROR:|WARNING:" "$RENAMEDLOG" | head -c 2048)
  notify "alert" "🛑 ALPHA backup complete with ERRORS:" "$LOGOUTPUT"
elif grep -q "WARNING:" "$RENAMEDLOG"; then
  LOGOUTPUT=$(grep "WARNING:" "$RENAMEDLOG" | head -c 2048)
  notify "warning" "⚠️ ALPHA backup complete with warnings:" "$LOGOUTPUT"
else
  notify "normal" "✅ ALPHA backup complete without error." "Have a nice day!"
fi

# Write out backup usage and free space
{
  echo "=== du report at $(date "+%Y-%m-%d %H:%M:%S") ==="
  docker exec rsnapshot-docker rsnapshot du
  echo
  echo "=== free space report ==="
  df -h /mnt/user
} >"$DULOG"

# Filter log for copied files
grep "\] >" "$RENAMEDLOG" > "$COPIEDLOG"

# Archive old logs
mkdir -p "$ARCHIVE"
find "$LOGDIR" -maxdepth 1 -type f -name "*.log" -mtime +15 | while read -r oldlog; do
  base=$(basename "$oldlog")
  mv "$oldlog" "$ARCHIVE/$base"
  gzip -f "$ARCHIVE/$base"
done
