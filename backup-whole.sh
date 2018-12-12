#!/bin/bash
# Use crontab to auto schedule
# Uses stuff to inject strings into the input buffer of a running window, assumes only running screen session

# Variables - Change to your needs
fileToBackup=$("/home/jordan/treescape")
backupLocation=$("/home/jordan/BACKUP/")
serverName=$("Treescape")
startScript=$("bash start.sh")

# Used to create a unique identifier for the file-name. Change if creating backup more than once a day!
current_day=$(date +"%m_%d_%Y")

# In-game warnings, wait 2 mins, stop and echo to screen. Waits between saving, stopping and compressing for HDDs
screen -p 0 -X stuff "say $serverName is restarting in 2 mins!$(printf \\r)"
sleep 1m
screen -p 0 -X stuff "say $serverName is restarting in 1 min!!$(printf \\r)"
sleep 1m
screen -p 0 -X stuff "say $serverName is restarting!$(printf \\r)"
screen -p 0 -X stuff "save-all$(printf \\r)"
sleep 5
screen -p 0 -X stuff "stop$(printf \\r)"
sleep 5
screen -p 0 -X stuff "echo WORLDS SAVED AND SERVER STOPPED. COMPRESSING BACKUP...$(printf \\r)"

tar -czPf $backupLocation-$current_day.tar.gz $fileToBackup

screen -p 0 -X stuff "echo BACKUP COMPLETE! RESTARTING SERVER...$(printf \\r)"
screen -p 0 -X stuff "$startScript $(printf \\r)"
