This is a personal project, not explicitly intended for outside consumption, so YMMV and I make no claims or warranty of any kind.  

This container setup has ssh and rsnapshot installed.
VOLUMES:
/config -> /mnt/cache/appdata/rsnapshot-docker #it will contain the following:
  logs/
  cron.daily/
  cron.weekly/
  rsnapshot.config  #this is symlinked from /etc/rsnapshot.conf
  rsnapshot.config.example #my config, sanitized a bit as a starting point for others.
  backup.list   #my exclude-from file
  ssh/ #mounted seperately as /root/.ssh to hold ssh keys and such persistently
/backup -> /mnt/user/backup #the backup destination
/foo -> additional mounted diretory to be backed up #this is a persistent SMB mount to another machine whose goodies I also want to back up

I run two of these, the one on my backup server has all the bells and whistles on (cron jobs, logs, etc.) on the backup server, and on the primary (source) server, I install it but dont' really configure anything.
