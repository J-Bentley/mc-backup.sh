## What is it?
A BASH script to automate restarting & local backups up of a Spigot/Paper/Minecraft server. Injects commands into an already running Screen session to issue in-game warnings to players, gracefully stops the server, then compresses the server directory or just plugin or world folders to a local backup directory before restarting the server gracefully.

## Setup    
* Open the script in any text editor and change these variables at the top:  

- **fileToBackup** = Your root server directory. *(dont include closing "/")*  

- **backupLocation** = The location to backup the compressed files to. *(dont include closing "/")*   

- **serverName** = The name of your server.  

- **startScript** = The command to restart the server. Keep in mind this is run from the screen session.  

- **serverWorlds** = An array of the servers world names for worldonly mode. Includes defaults, add any of your custom worlds here to be backed up seperated by a space. (ex: "arena" "lobby" "creative")  

Might require: ``sudo chmod +x mc-backup.sh``  

## Usage  

Spits out useful info to STDOUT and log file in running dir for manual execution but best when [automated with crontab](https://www.liquidweb.com/kb/create-a-cron-task-in-ubuntu-16-04/).

``bash mc-backup.sh [-h , -r , -w , -p] ``

- **No args:** Compresses entire server directory to backup location.  

- **-r | Restart:** Saves & restarts server with no backup made.  

- **-w | Worlds:** Compresses world directories only to backup location.   

- **-p | plugins:** Compresses plugin directory only to backup location.    

## UPDATES
- v6
	- Added check to determine if there is enough space on disk partition for 1 backup at start of script. 
	- All errors are logged to text file so if you crontab you will see if/why the script didn't complete.
- v5
	- Removed external gdrive.
	- Removed echos to screen session, only STDOUT/ERR to console & log.

## TODO
- Time stamps on log entries
- SMS sent upon success via twilio
- ftp to server set in an array
- plugin configuration files only mode
