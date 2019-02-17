
## What is it?
A BASH script to automate restarting & backing up of a Spigot/Paper/Minecraft server running on Ubuntu by injecting commands into an already running Screen session to issue in-game warnings to players, save the worlds, stop the server and then compress the server directory or just world folders to a backup location then upload remotely if desired and restart the server gracefully.

## Setup    
Be a man, open the script in a text editor and change these variables at the top:  

**fileToBackup** = Your root server directory. *(dont include closing "/")*  
**backupLocation** = The location to backup the compressed files to. *(dont include closing "/")*   
**serverName** = The name of your server.  
**startScript** = The command to restart the server. Keep in mind this is run from the screen session.  
**serverWorlds** = An array of the servers world names for worldonly mode. Includes defaults, add any of your custom worlds here to be backed up seperated by a space.  
**gdrivefolderid** = The ID of the folder you wish to upload to. Use "gdrive list" and copy/paste the ID here. Doesn't have to be set if not using gdrive mode.  
**currentDay** = A unique identifier for the file-name. Include %H for hour if doing more than once a day!  
**gracePeriod** = The time to wait between in-game warnings.  

Might require: ``sudo chmod +x mc-backup.sh``  

## Usage  

``bash mc-backup.sh [-h , -r , -w , -g , -wg] ``

- **No args:** Compresses entire server directory to backup location, does not upload to Gdrive.  

- **-r | Restart:** Issues warnings to players, saves & restarts server with no backup made.  

- **-w | Worlds:** Compresses world directories only to backup location, does not upload to Gdrive.  

- **-g | Gdrive:** Compresses entire server directory to backup location & uploads to Gdrive folder. 
[Requires Gdrive](https://olivermarshall.net/how-to-upload-a-file-to-google-drive-from-the-command-line/)  

- **-wg | Worlds&Gdrive:** Compresses world directories only to backup location & uploads to Gdrive folder.    

## UPDATES
- v2: echos time elapsed & file sizes, worldsonly mode, remote upload to gdrive

## TODO
- Error check if world files exist before tarring in world only mode
- Plugin only mode ala world only mode
- Email or text message sent upon success (twilio api)
- Change Gdrive to ftp or seafile, or add it. (with same worldonly functionality)
- If external upload is selected restart the server after tar is complete and let upload in background?
- Standardize ouput to screen/echo

