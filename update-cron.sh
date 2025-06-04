#!/bin/bash

CRONTAB_FILE="/etc/crontab"
LOGFILE="/config/logs/cron-update.log"
mkdir -p "$(dirname "$LOGFILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOGFILE"
}

# ======== DAILY JOB ==========
if [[ -z "$DAILY_TIME" ]]; then
    log "ERROR: DAILY_TIME is not set"
    exit 1
fi

if [[ ! "$DAILY_TIME" =~ ^([01]?[0-9]|2[0-3]):[0-5][0-9]$ ]]; then
    log "ERROR: DAILY_TIME must be in HH:MM format"
    exit 1
fi

DAILY_MINUTE="${DAILY_TIME##*:}"
DAILY_HOUR="${DAILY_TIME%%:*}"
DAILY_CMD='test -x /usr/sbin/anacron \|\| { cd / \&\& run-parts --report /etc/cron.daily; }'

if sed -i -E "s|^[0-9]{1,2} [0-9]{1,2}(\s+\*\s+\*\s+\*)\s+root\s+${DAILY_CMD}|\$DAILY_MINUTE \$DAILY_HOUR\1 root ${DAILY_CMD}|" "$CRONTAB_FILE"; then
    log "Updated daily cron to ${DAILY_HOUR}:${DAILY_MINUTE}"
else
    log "ERROR: Failed to update daily cron"
fi

# ======== WEEKLY JOB ==========
if [[ -z "$WEEKLY_TIME" || -z "$WEEKLY_DAY" ]]; then
    log "ERROR: WEEKLY_TIME and WEEKLY_DAY must be set"
    exit 1
fi

if [[ ! "$WEEKLY_TIME" =~ ^([01]?[0-9]|2[0-3]):[0-5][0-9]$ ]]; then
    log "ERROR: WEEKLY_TIME must be in HH:MM format"
    exit 1
fi

if [[ ! "$WEEKLY_DAY" =~ ^[1-7]$ ]]; then
    log "ERROR: WEEKLY_DAY must be an integer between 1 and 7"
    exit 1
fi

WEEKLY_MINUTE="${WEEKLY_TIME##*:}"
WEEKLY_HOUR="${WEEKLY_TIME%%:*}"
WEEKLY_CMD='test -x /usr/sbin/anacron \|\| { cd / \&\& run-parts --report /etc/cron.weekly; }'

if sed -i -E "s|^[0-9]{1,2} [0-9]{1,2}(\s+\*\s+\*\s+)[0-7]\s+root\s+${WEEKLY_CMD}|\$WEEKLY_MINUTE \$WEEKLY_HOUR\1$WEEKLY_DAY root ${WEEKLY_CMD}|" "$CRONTAB_FILE"; then
    log "Updated weekly cron to ${WEEKLY_HOUR}:${WEEKLY_MINUTE} on day ${WEEKLY_DAY}"
else
    log "ERROR: Failed to update weekly cron"
fi

# ======== MONTHLY JOB ==========
if [[ -z "$MONTHLY_TIME" || -z "$MONTHLY_DAY" ]]; then
    log "ERROR: MONTHLY_TIME and MONTHLY_DAY must be set"
    exit 1
fi

if [[ ! "$MONTHLY_TIME" =~ ^([01]?[0-9]|2[0-3]):[0-5][0-9]$ ]]; then
    log "ERROR: MONTHLY_TIME must be in HH:MM format"
    exit 1
fi

if [[ ! "$MONTHLY_DAY" =~ ^([1-9]|[12][0-9]|3[01])$ ]]; then
    log "ERROR: MONTHLY_DAY must be an integer between 1 and 31"
    exit 1
fi

MONTHLY_MINUTE="${MONTHLY_TIME##*:}"
MONTHLY_HOUR="${MONTHLY_TIME%%:*}"
MONTHLY_CMD='test -x /usr/sbin/anacron \|\| { cd / \&\& run-parts --report /etc/cron.monthly; }'

if sed -i -E "s|^[0-9]{1,2} [0-9]{1,2}(\s+)$MONTHLY_DAY(\s+\*\s+\*)\s+root\s+${MONTHLY_CMD}|\$MONTHLY_MINUTE \$MONTHLY_HOUR\1$MONTHLY_DAY\2 root ${MONTHLY_CMD}|" "$CRONTAB_FILE"; then
    log "Updated monthly cron to ${MONTHLY_HOUR}:${MONTHLY_MINUTE} on day ${MONTHLY_DAY}"
else
    log "ERROR: Failed to update monthly cron"
fi
