
## What is it?
A BASH script to automate restarting & backing up of a Spigot/Paper/Minecraft server running on Ubuntu by injecting commands into an already running Screen session to issue in-game warnings to players, save the worlds, stop the server and then compress the server directory or just world folders to a backup location then upload remotely if desired.

## Usage  

``bash mc-backup.sh [-h , -r , -w , -g , -wg] ``

- **No args:** Compresses entire server directory to backup location, does not upload to Gdrive.  

- **-r | Restart:** Issues warnings to players, saves & restarts server with no backup made.  

- **-w | Worlds:** Compresses world directories only to backup location, does not upload to Gdrive.  

- **-g | Gdrive:** Compresses entire server directory to backup location & uploads to Gdrive folder. 
[Requires Gdrive installed of course](https://olivermarshall.net/how-to-upload-a-file-to-google-drive-from-the-command-line/)  

- **-wg | Worlds&Gdrive:** Compresses world directories only to backup location & uploads to Gdrive folder.    



## Setup    
Be a man, open the script in a text editor and change these variables at the top:  

**fileToBackup** = Your root server directory. *(dont include closing "/")*  
**backupLocation** = The location to backup the compressed files to. *(dont include closing "/")*   
**serverName** = The name of your server.  
**startScript** = The command to restart the server. Keep in mind this is run from the screen session.  
**serverWorlds** = An array of the servers world names for worldonly mode. Includes defaults, add any of your custom worlds here to be backed up.  
**gdrivefolderid** = The ID of the folder you wish to upload to (required) use "gdrive list" and copy/paste the ID here. Doesn't have to be set if not using gdrive mode.  
**currentDay** = A unique identifier for the file-name. Include %H for hour if doing more than once a day!  
**gracePeriod** = The time to wait after first warning.  

Might require: ``sudo chmod +x mc-backup.sh``  

## TODO (version control lol)
- Worlds are entered as an array at top of script and then tarred like one. [✓]
- Print time elapsed and do some math to it [almost ✓]
- Email or text message sent upon success (twilio api)
- Change Gdrive to ftp or seafile, or add it. (with same worldonly functionality)
- If external upload is selected (gdrive/ftp/seafile) restart the server after tar is complete and let upload in background?
- Plugin only mode with remote upload a la world mode. Gonna get messy, need to streamline some code for that.. meh


