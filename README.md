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
**ftpCreds** = For FTP modes. (your username, remote ftp servers ip, password, remote directory)  
**gracePeriod** = The time to wait between in-game warnings. (Remove m for seconds)  

Might require: ``sudo chmod +x mc-backup.sh``  

## Usage  

Has useful output to STDOUT and to the running screen session for manual execution but best when [automated with crontab](https://www.liquidweb.com/kb/create-a-cron-task-in-ubuntu-16-04/).

``bash mc-backup.sh [-h , -r , -w , -p, -g, -f] ``

- **No args:** Compresses entire server directory to backup location, does not upload to Gdrive.  

- **-r | Restart:** Issues warnings to players, saves & restarts server with no backup made.  

- **-w | Worlds:** Compresses world directories only to backup location, does not upload to Gdrive.   

- **-p | plugins:** Compresses plugin directory only to backup location, does not upload to Gdrive.    

- **-g | Gdrive:** Compresses entire server directory to backup location & uploads to Gdrive folder. 
[Requires Gdrive](https://olivermarshall.net/how-to-upload-a-file-to-google-drive-from-the-command-line/) 

- **-f | FTP:** Compresses entire directory to backup directory and uploads to ftp server in ftpCreds  

## UPDATES
- v2
	- Echos time elapsed upon finish
	- Echos compressed/uncompressed folder sizes
	- Worlds only mode with custom world name support
	- Gdrive as external upload method (may change)
	- Error checking: world folders, server & backup folders, java running, only 1 screen session, gdrive check etc
	- Date formatted like windows does it 
- v3
    - Plugin only mode ala world only mode.
- v4
    - Cleaned up modes
    - Added FTP remote backup method
    - FTP & Gdrive backups do full backups only, world and plugin mode backups are only made locally.

## TODO
- Test it...
- Gdrive delete function before uploading (1 backup kept only, due to 15gb limit)
- Streamline modes and give full functionality (world, plugin modes) to remote backup (gdrive/ftp) modes.
- Email or text message sent upon success (via twilio api)
- Crontab tutorial of some sort in readme
