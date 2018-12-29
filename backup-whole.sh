#!/bin/bash
# Jordan Bentley 2018-12-15
# A Minecraft server backup/compression script that gracefully stops the server, with in-game warnings to players
# Uses stuff to inject strings into the input buffer of a running window, assumes only running screen session

# Variables - Change to your needs
fileToBackup="/home/jordan/treescape/"
backupLocation="/home/jordan/BACKUP/"
serverName="Treescape"
startScript="bash start.sh"

# A unique identifier for file-name - change if creating backup more than once a day
currentDay=$(date +"%m-%d-%Y")

if [ ! -d $fileToBackup ]; then
    echo "fileToBackup not found!"
    exit 1
fi

if [ ! -d $backupLocation ]; then
    echo "backupLocation not found!"
    exit 1
fi

echo "Backup/Compression of $serverName Initiated on $currentDay..."

screen -p 0 -X stuff "say $serverName is restarting in 2 minutes!$(printf \\r)"
sleep 1m
screen -p 0 -X stuff "say $serverName is restarting in 1 minute!!$(printf \\r)"
sleep 1m
screen -p 0 -X stuff "say $serverName is restarting now!$(printf \\r)"
screen -p 0 -X stuff "save-all$(printf \\r)"
sleep 5 # remove if you live like larry
screen -p 0 -X stuff "stop$(printf \\r)"
sleep 5 
screen -p 0 -X stuff "echo $serverName stopped! Compressing [$fileToBackup] to [$backupLocation] on [$currentDay] ...$(printf \\r)"

tar -czPf $backupLocation$serverName-$currentDay.tar.gz $fileToBackup
screen -p 0 -X stuff "echo Compression complete! Restarting $serverName... $(printf \\r)"
screen -p 0 -X stuff "$startScript $(printf \\r)"

echo "[$fileToBackup] compressed to [$backupLocation]:"
ls -a $backupLocation

exit 0
