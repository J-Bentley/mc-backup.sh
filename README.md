## What is it?
A BASH script to automate graceful restarting & local backups of a Spigot/Paper/Bukkit/Minecraft server running on Ubuntu in a Screen session.

## Setup   
Open the script in a text editor and change these variables at the top:  

- **fileToBackup** = Your root server directory. *(dont include closing "/")*  

- **backupLocation** = The location to backup the compressed files to. *(dont include closing "/")*   

- **serverName** = The name of your server.  

- **startScript** = The command to restart the server. Keep in mind this is run from the screen session.  

- **serverWorlds** = An array of the servers world directory names. Includes defaults, add any of your custom worlds, seperated by a space. (ex: "arena" "lobby" "creative")  

- Start a screen session with ``screen -S <id>``, deattach with ``ctrl+a+d``, and reattach with ``screen -R <id>`` if needed. Ensure there is only 1 screen session running with ``screen -ls``. 

## Usage  

``bash mc-backup.sh [-h , -r , -w , -p, -pc] ``

- **No args:** Gracefully stops the server if its running, compresses entire server directory to backup location and restarts server.  

- **-h | help:** Shows arguments/modes available.   

- **-r | Restart:** Saves & restarts server with no backup made.  

- **-w | Worlds:** Gracefully stops the server if its running, compresses world directories only to backup location and restarts server.   
- **-p | plugins:** Gracefully stops the server if its running, compresses plugin directory only to backup location and restarts server 

- **-pc | pluginconfig:** Gracefully stops the server if its running, compresses plugin config directories only to backup location and restarts server. Ignores plugin .jars.  

Best when automated with (Crontab)[https://www.thegeekstuff.com/2009/06/15-practical-crontab-examples/].  

Crontab examples:
- Gracefully restart server without backup every 12 hours:
- Backup just world files every day:
- Backup just plugin config files every week:
- Full server backup every week:

## CAVEATS
- Only 1 or no arg can be called at a time.
- only 1 screen session can be running on the system.
- No way to disable auto restart of the server after compression correctly. 
- TO FIX: Script will continue with 0 screens running and java not running but not if java is running and 0 screens. (already continues without exiting with 1 screen and java not running.) 
