#!/bin/bash
# Jordan Bentley 2018-12-15
# A Minecraft server backup/compression script that gracefully stops the server, with in-game warnings to players
# Uses stuff to inject strings into the input buffer of a running window, assumes only running screen session

# Variables - Change to your needs
fileToBackup="/home/jordan/treescape/"
backupLocation="/home/jordan/BACKUP/"
serverName="Treescape"
startScript="bash start.sh"

currentDay=$(date +"%m-%d-%Y") # Change if creating backup more than once a day
gdriveUpload=false
worldsOnly=false

gdrivefolderid="" #gdrive list

if [ ! -d $fileToBackup ]; then
    echo "fileToBackup not found!"
    exit 1
fi

if [ ! -d $backupLocation ]; then
    echo "backupLocation not found!"
    exit 1
fi

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      echo "args: -h, -g, -w"
      exit 0
      ;;
    -g|--gdrive)
      gdriveUpload=true
      ;;
    -w|--worlds)
      worldsOnly=true
      ;;
    *)
      echo "Invalid argument: "$1
      echo "args: -h | help, -g | gdrive, -w | worlds only"
      exit 1
      ;;

echo "Starting backup of $serverName on $currentDay..."

screen -p 0 -X stuff "say $serverName is restarting in 2 minutes!$(printf \\r)"
sleep 1m
screen -p 0 -X stuff "say $serverName is restarting in 1 minute!!$(printf \\r)"
sleep 1m
screen -p 0 -X stuff "say $serverName is restarting now!$(printf \\r)"
screen -p 0 -X stuff "save-all$(printf \\r)"
sleep 5
screen -p 0 -X stuff "stop$(printf \\r)"
sleep 5 
screen -p 0 -X stuff "echo $serverName stopped! Compressing [$fileToBackup] to [$backupLocation] on [$currentDay]...$(printf \\r)"

if [ "worldsOnly" = true ]; then
    tar -czPf $backupLocation$serverName-$currentDay.tar.gz $fileToBackup --include="/world" --include="/world_nether" --include="/world_the_end"
fi

tar -czPf $backupLocation$serverName-$currentDay.tar.gz $fileToBackup
screen -p 0 -X stuff "echo Compression complete!$(printf \\r)"

if [ "gdriveUpload" = true ]; then
	screen -p 0 -X stuff "echo Uploading to Gdrive... $(printf \\r)"
    gdrive upload -p $gdrivefolderid $backupLocation$serverName-$currentDay.tar.gz
fi

screen -p 0 -X stuff "echo Restarting $serverName... $(printf \\r)"
screen -p 0 -X stuff "$startScript $(printf \\r)"

echo "[$fileToBackup] compressed to [$backupLocation]:"
ls -a $backupLocation

exit 0
