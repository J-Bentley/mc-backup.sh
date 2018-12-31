A BASH script built to automatically issue in-game warnings to players, save the worlds, stop the server and compress the server directory or just world folders to a backup location then upload to gdrive if desired.

Has console feedback for manual usage but is best when automated with crontab.

SETUP:

*[Install Gdrive](https://olivermarshall.net/how-to-upload-a-file-to-google-drive-from-the-command-line/)*  
Find these variables at the top of the script and change to your needs.  
fileToBackup = Your root server directory.  
backupLocation= The location to backup the compressed files to.  
serverName= The name of your server.  
startScript= The command to restart the server. Keep in mind this is run from the screen session.  
gdrivefolderid= The ID of the folder you wish to upload to (required) use "gdrive list" and copy/paste the ID here.  

MODES  
No args: Compresses entire server directory to backup location.  
-r: Issues warnings to players, saves & restarts server with no backup made.  
-w: Worlds only mode, compresses the /world/, /world_nether/ & /world_the_end/ ONLY. Modify lines 97 & 93 to add more worlds!  
-g: Uploads to Gdrive. Requires installation & set gdrivefolderid variable to the folder ID you wish to upload to!  
-wg: Compress the worlds only and then upload them to gdrive.  
