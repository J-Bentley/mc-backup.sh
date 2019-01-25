#!/bin/bash
# Jordan Bentley 2018-12-15
# A compression script that gracefully stops a Minecraft server running on Screen, with in-game warnings to players and backup methods.

#--------- Change these ---------
fileToBackup="/home/me/MinecraftServer"
backupLocation="/home/me/Backup"
serverName="MyServer"
startScript="bash start.sh"
serverWorlds=("world" "world_nether" "world_the_end")
gdrivefolderid="NotSet"
currentDay=$(date +"%m-%d-%Y")
graceperiod="1m"
#---------------------------------

gdriveUpload=false
worldsOnly=false
worldUpload=false
restartOnly=false

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
  if ! ps -e | grep -q "gdrive"; then
    echo "Gdrive not installed! (No Gdrive process found)"
    exit 1
  elif ! gdrive list | grep -q "$gdrivefolderid"; then
    echo "Gdrive folder ID ($gdrivefolderid) not found or not installed!"
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
echo "Starting backup on $currentDay..."
elapsedTimeStart="$(date -u +%s)"
stopHandling

if $restartOnly; then
    screen -p 0 -X stuff "echo $serverName stopped!$(printf \\r)"
elif $worldsOnly; then
    screen -p 0 -X stuff "echo $serverName stopped! Compressing [$fileToBackup/worlds] to [$backupLocation] on [$currentDay]...$(printf \\r)"
    tar cf $backupLocation/$serverName[WORLDS]-$currentDay.tar --files-from /dev/null
    for item in "${serverWorlds[@]}"
    do
        tar rf $backupLocation/$serverName[WORLDS]-$currentDay.tar "$fileToBackup/$item"
    done
    gzip $backupLocation/$serverName[WORLDS]-$currentDay.tar
    screen -p 0 -X stuff "echo Compression complete!$(printf \\r)"
elif $worldUpload; then
    screen -p 0 -X stuff "echo $serverName stopped! Compressing [$fileToBackup/worlds*] to [$backupLocation] on [$currentDay] then uploading to Gdrive...$(printf \\r)"
    tar cf $backupLocation/$serverName[WORLDS]-$currentDay.tar --files-from /dev/null
    for item in "${serverWorlds[@]}"
    do
        tar rf $backupLocation/$serverName[WORLDS]-$currentDay.tar "$fileToBackup/$item"
    done
    gzip $backupLocation/$serverName[WORLDS]-$currentDay.tar
    screen -p 0 -X stuff "echo Compression complete! Uploading to Gdrive... $(printf \\r)"

    gdrive upload -p $gdrivefolderid $backupLocation/$serverName[WORLDS]-$currentDay.tar
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

elapsedTimeEnd="$(date -u +%s)"
screen -p 0 -X stuff "echo Starting $serverName... $(printf \\r)"
screen -p 0 -X stuff "$startScript $(printf \\r)"

if $restartOnly; then
    echo "$serverName restarted on $currentDay!"
else
    elapsed="$(($elapsedTimeEnd-$elapsedTimeStart/60))"
    compressedSize=$(du -sh $backupLocation* | cut -c 1-3)
    uncompressedSize=$(du -sh $fileToBackup* | cut -c 1-3)
    echo "[$fileToBackup] ($uncompressedSize) successfully compressed to [$backupLocation] ($compressedSize) in $elapsed minutes!"
fi

exit 0
