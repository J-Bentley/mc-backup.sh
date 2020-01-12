## What is it?
A BASH script to automate restarting & local backups up of a Spigot/Paper/Bukkit/Minecraft server. Injects commands into an already running Screen session to issue in-game warnings to players, gracefully saves and stops the server, compresses required server directories to a local backup directory then restarts the Minecraft server.

## Setup    
Open the script in any text editor and change these variables at the top:  

- **fileToBackup** = Your root server directory. *(dont include closing "/")*  

- **backupLocation** = The location to backup the compressed files to. *(dont include closing "/")*   

- **serverName** = The name of your server.  

- **startScript** = The command to restart the server. Keep in mind this is run from the screen session.  

- **serverWorlds** = An array of the servers world directory names. Includes defaults, add any of your custom worlds, seperated by a space. (ex: "arena" "lobby" "creative")  

Might require: ``sudo chmod +x mc-backup.sh``  

## Usage  

Can be manually executed with STDOUT and log file describing progress but best when [automated with crontab](https://www.liquidweb.com/kb/create-a-cron-task-in-ubuntu-16-04/).

``bash mc-backup.sh [-h , -r , -w , -p] ``

- **No args:** Compresses entire server directory to backup location.  

- **-h | help:** Shows arguments/modes available.   

- **-r | Restart:** Saves & restarts server with no backup made.  

- **-w | Worlds:** Compresses world directories only to backup location.   

- **-p | plugins:** Compresses plugin directory only to backup location.    

## UPDATES
- v6.1
	- PLugincConfig only mode added, like plugin mode but excludes the .jars
- v6
	- Added check to determine if there is enough space for 1 backup at start of script. 
	- All errors are saved to log file.

## TODO
- Time stamps on log entries
- SMS sent upon success via twilio
- ftp compressed files to a backup server w/ creds defined in array  

## CAVEATS
- 1 arg at a time bois
- wilitfit function checks to see if whole server will fit in backup location regardless of mode.
- Script will continue with 0 screens running and java not running but not if java is running and 0 screens. (already continues without exiting with 1 screen and java not running.) ???? idk
