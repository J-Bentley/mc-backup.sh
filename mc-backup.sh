#!/bin/bash
:'
MC-BACKUP version 4.0 
by Arcaniist 2018-12-15
https://github.com/J-Bentley/mc-backup.sh '
fileToBackup="/home/me/mcserver"
backupLocation="/home/me/mcbackup"
serverName="My Server"
startScript="bash start.sh"
graceperiod="1m"
serverWorlds=("world" "world_nether" "world_the_end")

bold=$(tput bold)
normal=$(tput sgr0)
currentDay=$(date +"%Y-%m-%d")
screens=$(ls /var/run/screen/S-$USER -1 | wc -l || 0)
serverRunning=true

worldsOnly=false
pluginOnly=false
restartOnly=false

stopHandling () {
  echo -e "Warning players & stopping $serverName ...\n"
  screen -p 0 -X stuff "say $serverName is restarting in $graceperiod!$(printf \\r)"
  sleep $graceperiod
  screen -p 0 -X stuff "say $serverName is restarting now!$(printf \\r)"
  screen -p 0 -X stuff "save-all$(printf \\r)"
  sleep 5
  screen -p 0 -X stuff "stop$(printf \\r)"
  sleep 5
}
worldfoldercheck () {
  #checks the server file for the world files in serverWorlds
  for item in "${serverWorlds[@]}"
  do
    if [! -d $backupLocation/$item ]; then
        echo "${bold}Error:${normal} World folder not found! ($backupLocation/$item)"
        echo -ne '\007'
        exit 1
	fi
  done
}
willitfit () {
  #makes a judgment based off the UNCOMPRESSED server folder size if it will fit in backupLocation
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
      echo -e "Usage:\nNo args | Compress $serverName's root dir\n-h | Help (this)\n-w | Compress worlds only\n-r | Restart with warnings, no backups made.\n-p | Compress plugins only\n"
      exit 0
      ;;
    -w|--worlds)
      worldfoldercheck
      worldsOnly=true
      ;;
    -p|--plugin)
      pluginOnly=true
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
    serverRunning=false
	#stopHandling wont be run if java isnt running
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
    echo -e "Usage:\nNo args | Compress $serverName's root dir\n-h | Help (this)\n-w | Compress worlds only\n-r | Restart with warnings, no backups made.\n-p | Compress plugins only\n"
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
	echo -e "Restart only on [$currentDay] ...\n"
elif $worldsOnly; then
    echo -e "Worlds only started on [$currentDay] ...\n"
    tar cf $backupLocation/$serverName[WORLDS]-$currentDay.tar --files-from /dev/null #starts the tar with files from the void so that multiple files can be looped in from array then gziped
	for item in "${serverWorlds[@]}"
    do
        tar rf $backupLocation/$serverName[WORLDS]-$currentDay.tar "$fileToBackup/$item"
    done
    gzip $backupLocation/$serverName[WORLDS]-$currentDay.tar
elif $pluginOnly; then
    echo -e "Plugins only started on [$currentDay] ...\n"
    tar -czPf $backupLocation/$serverName[PLUGINS]-$currentDay.tar.gz $fileToBackup/plugins
else
	echo -e "Full compression started on [$currentDay] ...\n"
	tar -czPf $backupLocation/$serverName-$currentDay.tar.gz $fileToBackup
fi

elapsedTimeEnd="$(date -u +%s)"
elapsed="$(($elapsedTimeEnd-$elapsedTimeStart))"

if $serverRunning || $restartOnly; then
    screen -p 0 -X stuff "$startScript $(printf \\r)"
    #wont restart server if it was offline upon script start--this could be a caveat
fi

if $restartOnly; then
    echo "$serverName restarted in $((elapsed/60)) minute(s)!"
elif $worldsOnly; then
	echo "Worlds compressed & $serverName restarted in $((elapsed/60)) minute(s)!"
elif $pluginOnly; then
	echo "Plugins compressed & $serverName restarted in $((elapsed/60)) minute(s)!"
else
    compressedSize=$(du -sh $backupLocation* | cut -c 1-3)
    uncompressedSize=$(du -sh $fileToBackup* | cut -c 1-3)
    echo "[$fileToBackup] ($uncompressedSize) compressed to [$backupLocation] ($compressedSize) in $((elapsed/60)) minutes!"
fi
exit 0
