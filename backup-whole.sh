#!/bin/bash
# Jordan Bentley 2018-12-15 v1
# A backup/compression script that gracefully stops the server, with in-game warnings to players

# --------- Change these ---------
fileToBackup="/home/jordan/treescape"
backupLocation="/home/jordan/BACKUP" # Don't include closing "/"
serverName="Treescape"
startScript="bash start.sh"
gdrivefolderid="1GkyWWtwF2dbKFo29E1GC9y1VVhj_UuFG" # gdrive list
currentDay=$(date +"%m-%d-%Y") # Change to +"%H" or "%M" if creating backup more than once a day
# ---------------------------------
 
gdriveUpload=false
worldsOnly=false
worldUpload=false
restartOnly=false

gdrivefoldercheck={
  if ! gdrive list | grep -q "$gdrivefolderid"; then
    echo "Gdrive folder ID not found!"
    exit 1
  fi
}

stopHandling={
  screen -p 0 -X stuff "say $serverName is restarting in 2 minutes!$(printf \\r)"
  sleep 1m
  screen -p 0 -X stuff "say $serverName is restarting in 1 minute!!$(printf \\r)"
  sleep 1m
  screen -p 0 -X stuff "say $serverName is restarting now!$(printf \\r)"
  screen -p 0 -X stuff "save-all$(printf \\r)"
  sleep 5
  screen -p 0 -X stuff "stop$(printf \\r)"
  sleep 5
}

if [ ! -d $fileToBackup ]; then
    echo "fileToBackup not found!"
    exit 1
fi

if [ ! -d $backupLocation ]; then
    echo "backupLocation not found!"
    exit 1
fi

if ! ps -e | grep "java"; then
    echo "$serverName is not running!"
    exit 1
fi

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      echo "A compression/backup/gdrive script of [$fileToBackup] to [$backupLocation] for $serverName!"
      echo "Args: -h | help, -r | Restart with warnings, -g | upload to gdrive, -w | compress worlds only, -wg | compress worlds only & upload to gdrive (both options)"
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
      echo "Invalid argument: "$1
      echo "Args: -h | help, -r | Restart with warnings, -g | upload to gdrive, -w | compress worlds only, -wg | compress worlds only & upload to gdrive (both options)"
      exit 1
      ;;
  esac
  shift
done

echo "Starting backup of $serverName on $currentDay..."
stopHandling

if $restartOnly; then
    stopHandling
elif $worldsOnly; then
    screen -p 0 -X stuff "echo $serverName stopped! Compressing [$fileToBackup/worlds] to [$backupLocation] on [$currentDay]...$(printf \\r)"
    tar cf $backupLocation/$serverName[WORLDS]-$currentDay.tar $fileToBackup/world/ $fileToBackup/world_nether/ $fileToBackup/world_the_end/ $fileToBackup/island/
    screen -p 0 -X stuff "echo Compression complete!$(printf \\r)"
elif $worldUpload; then
    screen -p 0 -X stuff "echo $serverName stopped! Compressing [$fileToBackup/worlds] to [$backupLocation] on [$currentDay] then uploading to Gdrive...$(printf \\r)"
    tar cf $backupLocation/$serverName[WORLDS]-$currentDay.tar $fileToBackup/world/ $fileToBackup/world_nether/ $fileToBackup/world_the_end/ $fileToBackup/island/
    screen -p 0 -X stuff "echo Compression complete!$(printf \\r)"

    screen -p 0 -X stuff "echo Uploading to Gdrive... $(printf \\r)"
    gdrive upload -p $gdrivefolderid $backupLocation$serverName-$currentDay.tar.gz
    screen -p 0 -X stuff "echo Upload complete! $(printf \\r)"
else
    screen -p 0 -X stuff "echo $serverName stopped! Compressing [$fileToBackup] to [$backupLocation] on [$currentDay]...$(printf \\r)"
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
    compressedSize=$(du -sh $backupLocation* | cut -c 1-5)
    uncompressedSize=$(du -sh $fileToBackup* | cut -c 1-5)
    echo "[$fileToBackup] ($uncompressedSize) compressed to [$backupLocation] ($compressedSize) :"
    ls -a $backupLocation
fi

#sleep 30
#screen -p 0 -X stuff "say Welcome back! $serverName weights $uncompressedSize.(printf \\r)"

exit 0
