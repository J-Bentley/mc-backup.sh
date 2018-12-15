#!/bin/bash
# Jordan Bentley 2018-12-15
# A Minecraft server backup/compression script that gracefully stops the server, with in-game warnings to players
# Uses "stuff" program to inject strings into the input buffer of a running window, assumes only 1 running screen session(!)

# Use Crontab to auto-schedule

# Can reduce or remove sleeps on lines 24 & 26 if using a SSD/not paranoid about world corruption

# Variables - Change to your needs
fileToBackup="/home/jordan/treescape"
backupLocation="/home/jordan/BACKUP/"
serverName="Treescape"
startScript="bash start.sh"
# Remember: this is executing from the screen session, assume its working directory

# Used to create a unique identifier for the file-name. Change if creating backup more than once a day!
current_day=$(date +"%m_%d_%Y")

# In-game warnings, wait 2 mins, stop and echo to screen. Waits between saving, stopping and compressing for HDDs
screen -p 0 -X stuff "say $serverName is restarting in 2 mins!$(printf \\r)"
sleep 1m
screen -p 0 -X stuff "say $serverName is restarting in 1 minute!!$(printf \\r)"
sleep 1m
screen -p 0 -X stuff "say $serverName is restarting!$(printf \\r)"
screen -p 0 -X stuff "save-all$(printf \\r)"
sleep 5
screen -p 0 -X stuff "stop$(printf \\r)"
sleep 5

screen -p 0 -X stuff "echo WORLDS SAVED AND $serverName STOPPED. COMPRESSING BACKUP...$(printf \\r)"
# echos to screen session

tar -czPf $backupLocation$serverName-$current_day.tar.gz $fileToBackup
# ex: /backup/location/servername-12_15_2018

screen -p 0 -X stuff "echo BACKUP COMPLETE! RESTARTING $serverName...$(printf \\r)"
screen -p 0 -X stuff "$startScript $(printf \\r)"
