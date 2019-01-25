
## What is it?
A BASH script built to automate restarting & backing up of a Minecraft server thats running on Ubuntu using screen by issuing in-game warnings to players, saving the worlds, stopping the server and then compress the server directory or just world folders to a backup location then upload to gdrive if desired.  


Has console feedback for manual usage but is best when **automated with crontab**.  

       

## Usage  

``bash mc-backup.sh [-h , -r , -w , -g , -wg] ``

- **No args:** Compresses entire server directory to backup location, does not upload to Gdrive.  

- **-r | Restart:** Issues warnings to players, saves & restarts server with no backup made.  

- **-w | Worlds:** Compresses world directories only to backup location, does not upload to Gdrive.  

- **-g | Gdrive:** Compresses entire server directory to backup location & uploads to Gdrive folder.  

- **-wg | Worlds&Gdrive:** Compresses world directories only to backup location & uploads to Gdrive folder.    

## Setup    
Simply open the script in a text editor and change these variables at the top:  

**fileToBackup** = Your root server directory. *(dont include closing "/")*  
**backupLocation** = The location to backup the compressed files to. *(dont include closing "/")*   
**serverName** = The name of your server.  
**startScript** = The command to restart the server. Keep in mind this is run from the screen session.  
**serverWorlds** = An array of the servers world names for worldonly mode. Includes defaults, add any of your custom worlds here to be backed up.  
**gdrivefolderid** = The ID of the folder you wish to upload to (required) use "gdrive list" and copy/paste the ID here. Doesn't have to be set if not using gdrive mode.  
**currentDay** = A unique identifier for the file-name. Include %H for hour if doing more than once a day!
**gracePeriod** = The time to wait after first warning.  

Might require: ``sudo chmod +x mc-backup.sh``  

## TODO
- Worlds are entered as an array at top of script and then tarred like one. [✓]
- Print time elapsed [✓]
- Email or text message sent upon success (twilio)
- Option to turn off output to running console as it should be run as crontab (does it matter though?)
- Change Gdrive to ftp or seafile, or add it. (with same worldonly functionality)
- If external upload is selected (gdrive/ftp/seafile) restart the server after tar is complete and let upload in background?


