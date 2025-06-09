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

I run two of these, the one on my backup server has all the bells and whistles on (cron jobs, logs, etc.) on the backup server, and on the primary (source) server, I install it but dont' really configure anything, it just acts as the ssh-target for the other one, with each backup source mounted as a root folder (eg /media)

A note about my backups:  
I have these lines configured in rsnapshot.conf:  
backup  root@tiamat:/media      tiamat  
backup  root@tiamat:/miscamin   tiamat  
backup  root@tiamat:/bigone     tiamat  
backup  /WallPaper      whelp  
backup  /NintendoSwitch whelp  

See the backup.list file for the exclusions that pare down those folders to just what I want to back up.  Note that I have my data folders mounted to the "source" container's root and my backup folder ends up containing one folder per system (tiamat and whelp) in each backup folder (eg alpha.0)
