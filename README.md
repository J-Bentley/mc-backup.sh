## What is it?
A BASH script to automate graceful restarting & local backups of a Minecraft server running in Screen on Ubuntu.

## Setup   
1. Open the script in a text editor and change these variables at the top:  
- **serverDir** = Your root server directory. *(dont include closing "/")*  
- **backupDir** = The location to backup the compressed files to. *(dont include closing "/")*   
- **serverName** = The name of your server.  
- **startScript** = The command to restart the server. Keep in mind this is run from the screen session.  
- **serverWorlds** = An array of the servers world directory names. Includes defaults, add any of your custom worlds, seperated by a space. (ex: "arena" "lobby" "creative")  

2. Manually start a screen session with ``screen -S <scren-id>``, deattach with ``ctrl + a + d``, and reattach with ``screen -r <screen-id>`` if needed. Ensure there is only 1 screen session running with ``screen -ls``.  

OR to autostart the server at boot AND in a screen session:
- `crontab -e`
- Add `@reboot sleep 60 && bash /path/to/server/start.sh` to end of file
- In your Minecraft server start.sh:  
```!#/bin/sh  
cd /path/to/server  
screen -dmS mc  
screen -p 0 -X stuff 'java -Xmx6G -Xmx7G -jar paper-*.jar\n'  
```
3. Within the screen session you created, start your minecraft server. Deattach from the screen session with ``ctrl + a + d`` and run the mc-backup.sh script from a seperate TTY.

## Usage  
``bash mc-backup.sh [-h , -r , -w , -p, -pc] ``

- **No args:** Gracefully stops the server if its running, compresses entire server directory to backup location and restarts server.  

- **-h | help:** Shows arguments/modes available.   

- **-r | Restart:** Saves & restarts server with no backup made.  

- **-w | Worlds:** Gracefully stops the server if its running, compresses world directories only to backup location and restarts server.   
- **-p | plugins:** Gracefully stops the server if its running, compresses plugin directory only to backup location and restarts server. Includes plugin .jars. 

- **-pc | pluginconfig:** Gracefully stops the server if its running, compresses plugin config directories only to backup location and restarts server. Ignores plugin .jars.  

**Best when automated with [Crontab](https://www.thegeekstuff.com/2009/06/15-practical-crontab-examples/).**  
Crontab examples:
- Gracefully restart server without backup every day at midnight: ```00 24 * * * bash /home/me/mc-backup.sh -r```
- Backup just world files every other day at midnight: ```00 24 * * 1,3,5 bash /home/me/mc-backup.sh -w```
- Backup just plugin config files every friday: ```00 24 * * 6 bash /home/me/mc-backup.sh -pc```
- Full server backup every monday at 8 AM: ```00 8 * * 1 bash /home/me/mc-backup.sh```

## CAVEATS
- Only 1 or no arg can be called at a time.
- only 1 screen session can be running on the system.
- No way to disable auto restart of the server after a successful compression. 
- Script will continue with 0 screens running and java not running but not if java is running and 0 screens. (already continues without exiting with 1 screen and java not running.) 
