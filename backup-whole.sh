#!/bin/bash
# Jordan Bentley 2018-12-15
# A Minecraft server backup/compression script that gracefully stops the server, with in-game warnings to players.
# Uses stuff to inject strings into the input buffer of a running window, assumes only 1 running screen session(!)
# Uses GDRIVE to upload compressed folder to google drive folder specified.

# Variables - Change to your needs!
fileToBackup="/home/jordan/treescape"
backupLocation="/home/jordan/BACKUP/"
gdriveFolderID="1GkyWWtwF2dbKFo29E1GC9y1VVhj_UuFG" # "gdrive list" to get folderID's
serverName="Treescape"
startScript="bash start.sh"

# A unique identifier for the file-name. Change if creating backup more than once a day!
currentDay=$(date +"%m_%d_%Y")

screen -p 0 -X stuff "say $serverName is restarting in 2 mins!$(printf \\r)"
sleep 1m
screen -p 0 -X stuff "say $serverName is restarting in 1 min!!$(printf \\r)"
sleep 1m
screen -p 0 -X stuff "say $serverName is restarting!$(printf \\r)"
screen -p 0 -X stuff "save-all$(printf \\r)"
sleep 5
screen -p 0 -X stuff "stop$(printf \\r)"
sleep 5
screen -p 0 -X stuff "echo Worlds saved and $serverName stopped. $(printf \\r)"

screen -p 0 -X stuff "echo Compressing backup on $currentDay...$(printf \\r)"
tar -czPf $backupLocation$serverName-$currentDay.tar.gz $fileToBackup
screen -p 0 -X stuff "echo Compression complete!

# screen -p 0 -X stuff "echo Uploading compressed backup to Gdrive on $currentDay... $(printf \\r)"
# gdrive upload -p $gdriveFolderID $backupLocation$serverName-$currentDay.tar.gz
# screen -p 0 -X stuff "echo Upload complete! $(printf \\r)"

screen -p 0 -X stuff "echo Restarting $serverName... $(printf \\r)"
screen -p 0 -X stuff "$startScript $(printf \\r)"
