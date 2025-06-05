#!/bin/bash
set -e

LOGFILE="/config/logs/startup-script.log"
mkdir -p "$(dirname "$LOGFILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOGFILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}


# 1. Copy /root/startup-config to /config without overwriting
log "Copying /root/startup-config to /config (without overwriting)..."
cp -a --update=none /root/startup-config/* /config/

# 2. Handle rsnapshot.conf
if [ ! -f /config/rsnapshot.conf ]; then
    log "Copying default rsnapshot.conf to /config..."
    cp /etc/rsnapshot.conf /config/rsnapshot.conf
fi

log "Replacing /etc/rsnapshot.conf with symlink to /config..."
rm -f /etc/rsnapshot.conf
ln -s /config/rsnapshot.conf /etc/rsnapshot.conf

# 3. Create cron.daily and cron.weekly under /config
log "Ensuring /config/cron.daily and /config/cron.weekly exist..."
mkdir -p /config/cron.daily
mkdir -p /config/cron.weekly

# 4. Symlink cron.daily rsnapshot script
if [ ! -f /config/cron.daily/rsnapshot ]; then
    log "/config/cron.daily/rsnapshot is missing, touching it."
    touch /config/cron.daily/rsnapshot
fi
log "Linking daily rsnapshot cron job to /config..."
ln -sf /config/cron.daily/rsnapshot /etc/cron.daily/rsnapshot
chmod 700 /config/cron.daily/rsnapshot

# 5. Symlink weekly rsnapshot cron script
if [ ! -f /config/cron.weekly/rsnapshot ]; then
    log "/config/cron.weekly/rsnapshot is missing, touching it."
    touch /config/cron.weekly/rsnapshot
fi
log "Linking weekly rsnapshot cron job to /config..."
ln -sf /config/cron.weekly/rsnapshot /etc/cron.weekly/rsnapshot
chmod 700 /config/cron.weekly/rsnapshot

# 6. Update the cron job times based on the environment variables.  See comments in script.
log "Running updatr-cron script"
/bin/bash /root/update-cron.sh 

# adding hosts file entries for our remote endpoint, if set.
if [[ -v REMOTE_NAME && -v REMOTE_IP ]]; then
    log "found /config/hosts. Adding contents to /etc/hosts"
    echo "${REMOTE_IP}  ${REMOTE_NAME}" >>/etc/hosts
fi

# 7. Run SSH daemon
log "Starting SSH daemon..."
exec /usr/sbin/sshd -D
