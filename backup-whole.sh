#!/bin/bash
# Jordan Bentley 2018-12-15
# A Minecraft server backup/compression script that gracefully stops the server, with in-game warnings to players
# Uses stuff to inject strings into the input buffer of a running window, assumes only running screen session

# Variables - Change to your needs
fileToBackup="/home/jordan/treescape"
backupLocation="/home/jordan/BACKUP/"
serverName="Treescape"
startScript="bash start.sh"

if [ ! -f $fileToBackup ]; then
    echo "fileToBackup not found!"
    exit 1
fi

if [ ! -f $backupLocation ]; then
    echo "backupLocation not found!"
    exit 1
fi

# A unique identifier for file-name - change if creating backup more than once a day
currentDay=$(date +"%m_%d_%Y")

echo "Backup/Compression Script Initiated on $currentDay."

screen -p 0 -X stuff "say $serverName is restarting in 2 minutes!$(printf \\r)"
sleep 1m
screen -p 0 -X stuff "say $serverName is restarting in 1 minute!!$(printf \\r)"
sleep 1m
screen -p 0 -X stuff "say $serverName is restarting now!$(printf \\r)"
screen -p 0 -X stuff "save-all$(printf \\r)"
sleep 5
screen -p 0 -X stuff "stop$(printf \\r)"
sleep 5
screen -p 0 -X stuff "echo Worlds saved and $serverName stopped. $(printf \\r)"

screen -p 0 -X stuff "echo Compressing backup on $currentDay...$(printf \\r)"
tar -czPf $backupLocation$serverName-$currentDay.tar.gz $fileToBackup
screen -p 0 -X stuff "echo Compression complete!"

screen -p 0 -X stuff "echo Restarting $serverName... $(printf \\r)"
screen -p 0 -X stuff "$startScript $(printf \\r)"

echo "$fileToBackup compressed to $backupLocation:"
ls -a $backupLocation

exit 0
