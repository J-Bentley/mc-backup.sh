#!/bin/bash
:'
MC-BACKUP version 4.0 
by Arcaniist 2018-12-15
https://github.com/J-Bentley/mc-backup.sh

Set these to your needs BEFORE running!'
fileToBackup="/home/me/MinecraftServer"
backupLocation="/home/me/Backup"
serverName="MyServer"
startScript="bash start.sh"
graceperiod="1m"
serverWorlds=("world" "world_nether" "world_the_end")
gdrivefolderid="notneededifnotusing"
ftpCreds=("user" "password" "ip" "/home/me/backup")
#----------------------------------

bold=$(tput bold)
normal=$(tput sgr0)

currentDay=$(date +"%Y-%m-%d")
currentTime=$(date + "${bold}[%H:%M]${normal}")
screens=$(ls /var/run/screen/S-$USER -1 | wc -l || 0)
serverRunning=true

gdriveUpload=false
ftpUpload=false
worldsOnly=false
pluginOnly=false
restartOnly=false

stopHandling () {
  screen -p 0 -X stuff "say $serverName is restarting in $graceperiod!$(printf \\r)"
  sleep $graceperiod
  screen -p 0 -X stuff "say $serverName is restarting now!$(printf \\r)"
  screen -p 0 -X stuff "save-all$(printf \\r)"
  sleep 5
  screen -p 0 -X stuff "stop$(printf \\r)"
  sleep 5
}
gdrivefoldercheck () { # NEEDS TESTING
  if ! ps -e | grep -q "gdrive"; then 
    echo "${bold}Error:${normal} Gdrive not installed or running!"
    echo -ne '\007'
    exit 1
  elif ! gdrive list | grep -q "$gdrivefolderid"; then 
    echo "${bold}Error:${normal} Gdrive folder ID ($gdrivefolderid) not found!"
    echo -ne '\007'
    exit 1
  fi
}
worldfoldercheck () {
  for item in "${serverWorlds[@]}"
  do
    if [! -d $backupLocation/$item ]; then
        echo "${bold}Error:${normal} World folder not found! ($backupLocation/$item)"
        echo -ne '\007'
        exit 1
  done
}
willitfit () {
  #Makes a judgment based off the UNCOMPRESSED server folder size if it will fit in backupLocation, although it may fit when COMPRESSED
  backupLocationFree=$(stat -c%s "$backupLocation")
  fileToBackupSize=$(stat -c%s "$fileToBackup")
  if [ $fileToBackupSize -gt $backupLocationFree ]; then
    echo "${bold}Error:${normal} Not enough free space in $backupLocation!"
    echo -ne '\007'
    exit 1
  fi
}

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      echo -e "\n${bold}MC-BACKUP by Arcaniist${normal}\n---------------------------\nA compression/backup script of\n[$fileToBackup] to [$backupLocation] for $serverName!\n"
      echo -e "Usage:\nNo args | Compress $serverName's root dir\n-h | Help (this)\n-w | Compress worlds only\n-r | Restart with warnings, no backups made.\n-g | Compress & upload $serverName's root dir to gdrive\n-wu | Compress & upload worlds to gdrive\n-p | Compress plugins only\n-pu | Compress & upload plugins to gdrive"
      exit 0
      ;;
    -g|--gdrive)
      gdrivefoldercheck
      gdriveUpload=true
      ;;
    -w|--worlds)
      worldfoldercheck
      worldsOnly=true
      ;;
    -p|--plugin)
      pluginOnly=true
      ;;
      ;;
    -r|--restart)
      restartOnly=true
      ;;
    *)
      echo -e "${bold}Invalid argument: ${normal}"$1 
      echo -e "Usage:\nNo args | Compress $serverName's root dir\n-h | Help (this)\n-w | Compress worlds only\n-r | Restart with warnings, no backups made.\n-g | Compress & upload $serverName's root dir to gdrive\n-wu | Compress & upload worlds to gdrive\n-p | Compress plugins only\n-pu | Compress & upload plugins to gdrive"      exit 1
      ;;
  esac
  shift
done

echo -e "\n${bold}MC-BACKUP by Arcaniist${normal}\n---------------------------\nA compression/backup script of\n[$fileToBackup] to [$backupLocation] for $serverName!\n"
echo "$currentTime Script started on $currentDay..."

if [ ! -d $fileToBackup ]; then
    echo "${bold}Error:${normal} Server folder not found! ($fileToBackup)"
    echo -ne '\007'
    exit 1
fi

if [ ! -d $backupLocation ]; then
    echo "${bold}Error:${normal} Backup folder not found! ($backupLocation)"
    echo -ne '\007'
    exit 1
fi

if ! ps -e | grep -q "java"; then
    echo "${bold}Warning:${normal} $serverName is not running! Continuing without in-game warnings..."
    echo -ne '\007'
    serverRunning=false #stopHandling wont be run
fi

if [ $screens -eq 0 ]; then
    echo "${bold}Error:${normal} No screen sessions running!"
    echo -ne '\007'
    exit 1
elif [ $screens -gt 1 ]; then
    echo "${bold}Error:${normal} More than 1 screen session is running, am confuse!"
    echo -ne '\007'
    exit 1
fi

if [ $# -gt 1 ]; then
    echo -e "${bold}Too many arguments!${normal}"
    echo -e "Usage:\nNo args | Compress $serverName's root dir\n-h | Help (this)\n-w | Compress worlds only\n-r | Restart with warnings, no backups made.\n-g | Compress & upload $serverName's root dir to gdrive\n-wu | Compress & upload worlds to gdrive\n-p | Compress plugins only\n-pu | Compress & upload plugins to gdrive"
    echo -ne '\007'
    exit 1
fi

if ! $restartOnly; then
    willitfit
fi

if $serverRunning; then
    stopHandling
fi

elapsedTimeStart="$(date -u +%s)"

if $restartOnly; then
    screen -p 0 -X stuff "echo $currentTime $serverName stopped! Restarting $serverName...$(printf \\r)"
elif $worldsOnly; then
    screen -p 0 -X stuff "echo $currentTime $serverName stopped! Compressing [$fileToBackup/worlds] to [$backupLocation] on [$currentDay]...$(printf \\r)"
    tar cf $backupLocation/$serverName[WORLDS]-$currentDay.tar --files-from /dev/null #starts the tar with files from the void so that multiple files can be looped in from array then gziped
    for item in "${serverWorlds[@]}"
    do
        tar rf $backupLocation/$serverName[WORLDS]-$currentDay.tar "$fileToBackup/$item"
    done
    gzip $backupLocation/$serverName[WORLDS]-$currentDay.tar
    screen -p 0 -X stuff "echo $currentTime Compression complete! Restarting $serverName...$(printf \\r)"
elif $pluginOnly; then
    screen -p 0 -X stuff "echo $currentTime $serverName stopped! Compressing [$fileToBackup/plugins] to [$backupLocation] on [$currentDay]...$(printf \\r)"
    tar -czPf $backupLocation/$serverName[PLUGINS]-$currentDay.tar.gz $fileToBackup/plugins
    screen -p 0 -X stuff "echo $currentTime Compression complete! Restarting $serverName...$(printf \\r)"
else
    screen -p 0 -X stuff "echo $currentTime $serverName stopped! Compressing [$fileToBackup/] to [$backupLocation/] on [$currentDay]...$(printf \\r)"
    tar -czPf $backupLocation/$serverName-$currentDay.tar.gz $fileToBackup
    screen -p 0 -X stuff "echo $currentTime Compression complete! Restarting $serverName...$(printf \\r)"
fi

if $gdriveUpload; then
    screen -p 0 -X stuff "echo $currentTime Uploading to Gdrive... $(printf \\r)"
    gdrive upload -p $gdrivefolderid $backupLocation/$serverName-$currentDay.tar.gz
    screen -p 0 -X stuff "echo $currentTime Upload complete! Restarting $serverName...$(printf \\r)"
elif $ftpUpload; then
    ftp ${ftpCreds[1]}@${ftpCreds[3]}
    echo ${ftpCreds[2]}
    cd ${ftpCreds[4]}
    lcd $backupLocation
    put $serverName-$currentDay.tar.gz
    bye
fi

elapsedTimeEnd="$(date -u +%s)"
elapsed="$(($elapsedTimeEnd-$elapsedTimeStart))"
screen -p 0 -X stuff "$startScript $(printf \\r)"

if $restartOnly; then
    echo "$serverName $currentTime restarted on $currentDay in $((elapsed/60)) minute(s)!"
else
    compressedSize=$(du -sh $backupLocation* | cut -c 1-3)
    uncompressedSize=$(du -sh $fileToBackup* | cut -c 1-3)
    echo "$currentTime [$fileToBackup] ($uncompressedSize) compressed to [$backupLocation] ($compressedSize) in $((elapsed/60)) minutes!"
fi
exit 0