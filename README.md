This is a personal project, not explicitly intended for outside consumption, so YMMV and I make no claims or warranty of any kind.  

This container setup has ssh and rsnapshot installed.  I am running on Unraid, so if you are not, adjust accordingly.

VOLUMES:  

/config -> /mnt/cache/appdata/rsnapshot-docker #it will contain the following:  
  - logs/  
  - rsnapshot.config  **this is symlinked from /etc/rsnapshot.conf**  
  - rsnapshot.config.example **my config, sanitized a bit as a starting point for others.**  
  - backup.list   **my exclude-from file**  
  - ssh/ **mounted seperately as /root/.ssh to hold ssh keys and such persistently**  

/backup -> /mnt/user/backup **the backup destination**  

/foo -> additional mounted diretory to be backed up **for me, this is a persistent SMB mount to another machine whose goodies I also want to back up**  

I run two of these, the one on my backup server has all the bells and whistles on (scheduled jobs, logs, etc.) on the backup server, and on the primary (source) server, I install it but dont' really configure anything other than ssh keys, it just acts as the ssh-target for the other one, with each backup source mounted as a root folder (eg /media)

Note: this won't do a damn thing without additional configuration and an external script to kick off the backup with "docker exec rsnapshot-docker rsnapshot alpha" or similar.  I have included in /extras/ a copy of my script that kicks off the backups and manages logs and alerting.

A note about my backups:  
I have these "backup" lines in my conf file pretty broad, but see the backup.list file for the exclusions that pare down those folders to just what I want to back up.  Note that I have my data folders mounted to the "source" container's root and my backup folder ends up containing one folder per system (unraid1 and htpc) in each backup folder (eg alpha.0/unraid1/media/Movies/Star Wars (1977)/).
