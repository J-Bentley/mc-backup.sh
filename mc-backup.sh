#!/bin/bash
# Jordan Bentley 12-2018 v1

# --------- Change these ---------
fileToBackup="/home/me/myserver" # Server root directory
backupLocation="/home/me/backup" # Backup directory
serverName="MyServer"
startScript="bash start.sh"
gdrivefolderid="1234455sdkhfjb2434234_e2sdfg4" # "gdrive list" to find
currentDay=$(date +"%m-%d-%Y") # Change to +"%H" or "%M" if backing up more than once a day
# ---------------------------------
 
gdriveUpload=false
worldsOnly=false
worldUpload=false
restartOnly=false

graceperiod="1m"
screens=$(ls /var/run/screen/S-$USER -1 | wc -l || 0)

bold=$(tput bold)
normal=$(tput sgr0)

stopHandling () {
  screen -p 0 -X stuff "say $serverName is restarting in $graceperiod!$(printf \\r)"
  sleep $graceperiod
  screen -p 0 -X stuff "say $serverName is restarting now!!$(printf \\r)"
  screen -p 0 -X stuff "save-all$(printf \\r)"
  sleep 5
  screen -p 0 -X stuff "stop$(printf \\r)"
  sleep 5
}

gdrivefoldercheck () {
  if ! gdrive list | grep -q "$gdrivefolderid"; then
    echo "Gdrive folder ID ($gdrivefolderid) not found or not installed!"
    gdrive list
    exit 1
  fi
}

if [ ! -d $fileToBackup ]; then
    echo "fileToBackup not found!"
    exit 1
fi

if [ ! -d $backupLocation ]; then
    echo "backupLocation not found!"
    exit 1
fi

if ! ps -e | grep -q "java"; then
    echo "$serverName is not running! (No Java process found)"
    exit 1
fi

if [ $screens -eq 0 ]; then
    echo "No screen sessions running!"
    exit 1
elif [ $screens -gt 1 ]; then
    echo "More than 1 screen session is running, am confuse!"
    screen -ls
    exit 1
fi

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      echo -e "\n${bold}MC-BACKUP by Arcaniist${normal}\n---------------------------\nA compression/backup script of\n[$fileToBackup] to [$backupLocation] for $serverName!\n"
      echo -e "Usage:\nNo args | Compress $serverName's root dir\n-h | Help (this)\n-w | Compress worlds only\n-r | Restart with warnings, no backups made.\n-g | Compress & upload $serverName's root dir to gdrive\n-wg | Compress & upload worlds to gdrive\n"
      exit 0
      ;;
    -g|--gdrive)
      gdrivefoldercheck
      gdriveUpload=true
      ;;
    -w|--worlds)
      worldsOnly=true
      ;;
    -wg|--worldupload)
      gdrivefoldercheck
      worldUpload=true
      ;;
    -r|--restart)
      restartOnly=true
      ;;
    *)
      echo -e "${bold}Invalid argument: ${normal}"$1 
      echo -e "Usage:\nNo args | Compress $serverName's root dir to backup dir\n-h | Help (this)\n-w | Compress worlds only\n-r | Restart with warnings, no backups made.\n-g | Compress & upload $serverName's root dir to gdrive\n-wg | Compress & upload worlds to gdrive\n"
      exit 1
      ;;
  esac
  shift
done

echo -e "\n${bold}MC-BACKUP by Arcaniist${normal}\n---------------------------\nA compression/backup script of\n[$fileToBackup] to [$backupLocation] for $serverName!\n"
echo "Starting backup script of $serverName on $currentDay..."
stopHandling

if $restartOnly; then
    screen -p 0 -X stuff "echo $serverName stopped!$(printf \\r)"
elif $worldsOnly; then
    screen -p 0 -X stuff "echo $serverName stopped! Compressing [$fileToBackup/worlds] to [$backupLocation] on [$currentDay]...$(printf \\r)"
    tar cf $backupLocation/$serverName[WORLDS]-$currentDay.tar $fileToBackup/world/ $fileToBackup/world_nether/ $fileToBackup/world_the_end/ $fileToBackup/island/
    screen -p 0 -X stuff "echo Compression complete!$(printf \\r)"
elif $worldUpload; then
    screen -p 0 -X stuff "echo $serverName stopped! Compressing [$fileToBackup/worlds*] to [$backupLocation] on [$currentDay] then uploading to Gdrive...$(printf \\r)"
    tar cf $backupLocation/$serverName[WORLDS]-$currentDay.tar $fileToBackup/world/ $fileToBackup/world_nether/ $fileToBackup/world_the_end/ $fileToBackup/island/
    screen -p 0 -X stuff "echo Compression complete!$(printf \\r)"

    screen -p 0 -X stuff "echo Uploading to Gdrive... $(printf \\r)"
    gdrive upload -p $gdrivefolderid $backupLocation$serverName-$currentDay.tar.gz
    screen -p 0 -X stuff "echo Upload complete! $(printf \\r)"
else
    screen -p 0 -X stuff "echo $serverName stopped! Compressing [$fileToBackup/] to [$backupLocation/] on [$currentDay]...$(printf \\r)"
    tar -czPf $backupLocation/$serverName-$currentDay.tar.gz $fileToBackup
    screen -p 0 -X stuff "echo Compression complete!$(printf \\r)"
fi

if $gdriveUpload; then
    screen -p 0 -X stuff "echo Uploading to Gdrive... $(printf \\r)"
    gdrive upload -p $gdrivefolderid $backupLocation/$serverName-$currentDay.tar.gz
    screen -p 0 -X stuff "echo Upload complete! $(printf \\r)"
fi

screen -p 0 -X stuff "echo Restarting $serverName... $(printf \\r)"
screen -p 0 -X stuff "$startScript $(printf \\r)"

if $restartOnly; then
    echo "$serverName restarted on $currentDay!"
else
    compressedSize=$(du -sh $backupLocation* | cut -c 1-4)
    uncompressedSize=$(du -sh $fileToBackup* | cut -c 1-4)
    echo "[$fileToBackup] ($uncompressedSize) successfully compressed to [$backupLocation] ($compressedSize):"
    ls -a $backupLocation
fi

#sleep $graceperiod
#screen -p 0 -X stuff "say Welcome back! $serverName weights $uncompressedSize!(printf \\r)"

exit 0
