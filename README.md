
## What is it?
A BASH script built to automate restarting & backing up of a Minecraft server thats running on Ubuntu using screen by issuing in-game warnings to players, saving the worlds, stopping the server and then compress the server directory or just world folders to a backup location then upload to gdrive if desired.  


Has console feedback for manual usage but is best when **automated with crontab**.  

       

## Usage  

``bash mc-backup.sh [-h , -r , -w , -g , -wg ] ``

- **No args:** Compresses entire server directory to backup location, does not upload to Gdrive.  

- **-r | Restart:** Issues warnings to players, saves & restarts server with no backup made.  

- **-w | Worlds:** Worlds only mode, compresses the ``/world/, /world_nether/ & /world_the_end/`` ONLY. Modify lines 97 & 93 to add more worlds!  

- **-g | Gdrive:** Compresses entire server directory & uploads to Gdrive folder.  

- **-wg | Worlds&Gdrive:** Compress the worlds only and then upload them to gdrive.  

## Setup  
*[Install Gdrive](https://olivermarshall.net/how-to-upload-a-file-to-google-drive-from-the-command-line/)* *(not required if not using)*  

Find these variables at the top of the script and change:  

**fileToBackup** = Your root server directory. *(dont include closing "/")*  
**backupLocation** = The location to backup the compressed files to. *(dont include closing "/")*   
**serverName** = The name of your server.  
**startScript** = The command to restart the server. Keep in mind this is run from the screen session.  
**gdrivefolderid** = The ID of the folder you wish to upload to (required) use "gdrive list" and copy/paste the ID here. Doesn't have to be set if not using gdrive mode.  

Might require: ``sudo chmod +x mc-backup.sh``  

##TODO
 - Worlds are entered as an array at top of script and then tarred like one, instead of manually adding the world dir to the tar command if you have more worlds than the default world, nether, end.
 - Better output to screen
- Option to turn off output to running console as it should be run as crontab (does it matter though?)
- Change Gdrive to ftp or seafile, or add it


