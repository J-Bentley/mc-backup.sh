
## What is it??
A BASH script built to automate restarting & backing up of a Minecraft server on Ubuntu using screen by issuing in-game warnings to players, saving the worlds, stopping the server and then compress the server directory or just world folders to a backup location then upload to gdrive if desired.  


Has console feedback for manual usage but is best when **automated with crontab**.  
*examples:* Backs up worlds only every 6 hours  
          Backs up whole directory every day  
          Backs up whole directrory to Gdrive every other day  
          Backs up worlds only to Gdrive every other day  
       

## Modes  

``bash mc-backup.sh [-h | Help, -r | Restart only with no backup, -w | Backup worlds only, -g | upload whole to Gdrive, -wg | Upload worlds only to Gdrive``

No args: Compresses entire server directory to backup location, does not upload to Gdrive.  
-r: Issues warnings to players, saves & restarts server with no backup made.  
-w: Worlds only mode, compresses the ``/world/, /world_nether/ & /world_the_end/`` ONLY. Modify lines 97 & 93 to add more worlds!  
-g: Compresses entire server directory & uploads to Gdrive folder.  
-wg: Compress the worlds only and then upload them to gdrive.  

## Setup  
*[Install Gdrive](https://olivermarshall.net/how-to-upload-a-file-to-google-drive-from-the-command-line/)* *(not required if not using)*  

Find these variables at the top of the script and change:  

**fileToBackup** = Your root server directory. *(dont include closing "/")*  
**backupLocation** = The location to backup the compressed files to. *(dont include closing "/")*   
**serverName** = The name of your server.  
**startScript** = The command to restart the server. Keep in mind this is run from the screen session.  
**gdrivefolderid** = The ID of the folder you wish to upload to (required) use "gdrive list" and copy/paste the ID here. Doesn't have to be set if not using gdrive mode.  


