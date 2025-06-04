#!/bin/bash
set -e

# 1. Copy /root/startup-config to /config without overwriting
echo "Copying /root/startup-config to /config (without overwriting)..."
cp -an /root/startup-config/* /config/

# 2. Handle rsnapshot.conf
if [ ! -f /config/rsnapshot.conf ]; then
    echo "Copying default rsnapshot.conf to /config..."
    cp /etc/rsnapshot.conf /config/rsnapshot.conf
fi

echo "Replacing /etc/rsnapshot.conf with symlink to /config..."
rm -f /etc/rsnapshot.conf
ln -s /config/rsnapshot.conf /etc/rsnapshot.conf

# 3. Create cron.daily and cron.weekly under /config
echo "Ensuring /config/cron.daily and /config/cron.weekly exist..."
mkdir -p /config/cron.daily
mkdir -p /config/cron.weekly

# 4. Symlink cron.daily rsnapshot script
if [ ! -f /config/cron.daily/rsnapshot ]; then
    touch /config/cron.daily/rsnapshot
    echo "Linking daily rsnapshot cron job to /config..."
    ln -sf /etc/cron.daily/rsnapshot /config/cron.daily/rsnapshot
fi

# 5. Symlink weekly rsnapshot cron script
if [ ! -f /config/cron.weekly/rsnapshot ]; then
    touch /config/cron.weekly/rsnapshot
    echo "Linking weekly rsnapshot cron job to /config..."
    ln -sf /etc/cron.weekly/rsnapshot /config/cron.weekly/rsnapshot
fi

# 6. Run SSH daemon
echo "Starting SSH daemon..."
exec /usr/sbin/sshd -D
