
## What is it?
A BASH script to automate restarting & backing up of a Spigot/Paper/Minecraft server running on Ubuntu by injecting commands into an already running Screen session to issue in-game warnings to players, save the worlds, stop the server and then compress the server directory or just world folders to a backup location then upload remotely if desired and restart the server gracefully.

## Setup    
Be a man, open the script in a text editor and change these variables at the top:  

**fileToBackup** = Your root server directory. *(dont include closing "/")*  
**backupLocation** = The location to backup the compressed files to. *(dont include closing "/")*   
**serverName** = The name of your server.  
**startScript** = The command to restart the server. Keep in mind this is run from the screen session.  
**serverWorlds** = An array of the servers world names for worldonly mode. Includes defaults, add any of your custom worlds here to be backed up seperated by a space. (ex: "arena" "lobby")  
**gdrivefolderid** = The ID of the folder you wish to upload to. Use "gdrive list" and copy/paste the ID here. Doesn't have to be set if not using gdrive mode.  
**currentDay** = A unique identifier for the file-name, don't have to change. Include %H for hour if doing more than once a day! (DON'T use minutes)  
**gracePeriod** = The time to wait between in-game warnings. (Remove m for seconds)  

Might require: ``sudo chmod +x mc-backup.sh``  

## Usage  

Has useful output to STDOUT and to the running screen session for manual execution but best when [automated with crontab](https://www.liquidweb.com/kb/create-a-cron-task-in-ubuntu-16-04/).

``bash mc-backup.sh [-h , -r , -w , -g , -wg, -p, -pu] ``

- **No args:** Compresses entire server directory to backup location, does not upload to Gdrive.  

- **-r | Restart:** Issues warnings to players, saves & restarts server with no backup made.  

- **-w | Worlds:** Compresses world directories only to backup location, does not upload to Gdrive.  

- **-g | Gdrive:** Compresses entire server directory to backup location & uploads to Gdrive folder. 
[Requires Gdrive](https://olivermarshall.net/how-to-upload-a-file-to-google-drive-from-the-command-line/)  

- **-wu | Worldupload:** Compresses world directories only to backup location & uploads to Gdrive folder.    

- **-p | plugins:** Compresses plugin directory only to backup location, does not upload to Gdrive.    

- **-pu | Pluginupload:** Compresses plugin directory only to backup location & uploads to Gdrive folder.    

## UPDATES
- v2
	- Echos time elapsed upon finish
	- Echos compressed/uncompressed folder sizes
	- Worlds only mode with custom world name support
	- Gdrive as external upload method (may change)
	- Error checking: world folders, server & backup folders, java running, only 1 screen session, gdrive check etc
	- Date formatted like windows does it 
- v3
    - Plugin only mode with external upload option like world only mode
	
## TODO
- Streamline the modes instead of seperating(?)
- Email or text message sent upon success (twilio api)
- Change Gdrive to ftp or seafile, or add it. (with same worldonly functionality)
- If external upload is selected restart the server after tar is complete and let upload in background?
- Standardize ouput to screen and/or echo
- Crontab tutorial of some sort in readme

