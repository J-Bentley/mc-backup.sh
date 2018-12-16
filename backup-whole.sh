#!/bin/bash
# Jordan Bentley 2018-12-15
# A Minecraft server backup/compression script that gracefully stops the server, with in-game warnings to players.
# Uses stuff to inject strings into the input buffer of a running window, assumes only 1 running screen session though!

# Variables - Change to your needs
fileToBackup="/home/jordan/treescape"
backupLocation="/home/jordan/BACKUP/"
serverName="Treescape"
startScript="bash start.sh"

# Used to create a unique identifier for the file-name. Change if creating backup more than once a day!
current_day=$(date +"%m_%d_%Y")

# In-game warnings, wait 2 mins, stop and echo to screen. Waits between saving, stopping and compressing for HDDs
echo "Issuing warnings..."
screen -p 0 -X stuff "say $serverName is restarting in 2 mins!$(printf \\r)"
sleep 1m
screen -p 0 -X stuff "say $serverName is restarting in 1 min!!$(printf \\r)"
sleep 1m
screen -p 0 -X stuff "say $serverName is restarting!$(printf \\r)"
screen -p 0 -X stuff "save-all$(printf \\r)"
sleep 5
screen -p 0 -X stuff "stop$(printf \\r)"
sleep 5
screen -p 0 -X stuff "echo Worlds saved and $serverName stopped. Compressing backup...$(printf \\r)"| tr a-z A-Z

echo "Starting compression of $fileToBackup to $backupLocation..."| tr a-z A-Z
tar -czPf $backupLocation$serverName-$current_day.tar.gz $fileToBackup
echo "Backup created on $current_day!"| tr a-z A-Z

screen -p 0 -X stuff "echo backup complete! restarting $serverName...$(printf \\r)"| tr a-z A-Z
screen -p 0 -X stuff "$startScript $(printf \\r)"
