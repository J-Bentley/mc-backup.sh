#!/bin/bash
# Jordan Bentley 2018-12-15
# A Minecraft server backup/compression script that gracefully stops the server, with in-game warnings to players.
# Uses stuff to inject strings into the input buffer of a running window, assumes only 1 running screen session(!)
# Uses GDRIVE to upload compressed folder to google drive folder specified.

# Variables - Change to your needs!
fileToBackup="/home/jordan/treescape"
backupLocation="/home/jordan/BACKUP/"
gdriveFolderID="gdrive list and paste here"
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
screen -p 0 -X stuff "echo Worlds saved and $serverName stopped. Compressing backup...$(printf \\r)"

tar -czPf $backupLocation$serverName-$currentDay.tar.gz $fileToBackup

screen -p 0 -X stuff "echo Compression complete. Uploading to gdrive...$(printf \\r)"

gdrive upload -p $gdriveFolderID $backupLocation$serverName-$currentDay.tar.gz

screen -p 0 -X stuff "echo Upload complete! Restarting $serverName... $(printf \\r)"
screen -p 0 -X stuff "$startScript $(printf \\r)"
