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
    log "Copying eample rsnapshot.conf to /config..."
    mv /config/rsnapshot.conf.example /config/rsnapshot.conf
fi
if [ -f /etc/rsnapshot.conf ]; then
    log "Removing rsnapshot.conf from /etc and creating symlink to /config"
    rm -f /etc/rsnapshot.conf
    ln -s /config/rsnapshot.conf /etc/rsnapshot.conf
fi

# adding hosts file entries for our remote endpoint, if set.
if [[ -v REMOTE_NAME && -v REMOTE_IP ]]; then
    log "Adding ${REMOTE_NAME} = ${REMOTE_IP} to /etc/hosts"
    echo "${REMOTE_IP}  ${REMOTE_NAME}" >>/etc/hosts
fi

# 7. Run SSH daemon
log "Starting SSH daemon..."
exec /usr/sbin/sshd -D
