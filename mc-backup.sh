#!/bin/bash
: '
MC-BACKUP version 6.0
by Arcaniist 2018-12-15
https://github.com/J-Bentley/mc-backup.sh '

fileToBackup="/home/me/minecraftserver"
backupLocation="/home/me/backup"
serverName="MyServer"
startScript="bash start.sh"
graceperiod="1m"
serverWorlds=("world" "world_nether" "world_the_end")

bold=$(tput bold)
normal=$(tput sgr0)
currentDay=$(date +"%Y-%m-%d")
screens=$(ls /var/run/screen/S-$USER -1 | wc -l || 0) #screen stores a .txt per session, finds how many.
serverRunning=true

worldsOnly=false
pluginOnly=false
restartOnly=false

log () {
    # echos text paseed to function and appends to log file at same time
    builtin echo -e "$@" | tee -a mc-backup_log.txt
}
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
    # Checks to make sure all the worlds defined in serverWorlds array exist as directories
    for item in "${serverWorlds[@]}"
    do
        if [! -d $backupLocation/$item ]; then
            log "${bold}Error:${normal} World folder not found! ($backupLocation/$item)\n"
            exit 1
	    fi
    done
}
willitfit () {
    freespace=$(df -k --output=avail "$PWD" | tail -n1) # Get current partition available in kb
    fileToBackupsize=$(du -s "$fileToBackup" | cut -f1) # Get server folder size in kb -- ** INNACURATE when in plugin/world only mode but still a good metric **
    if [[ freespace <= fileToBackupsize ]]; then
        log "${bold}Error:${normal} Not enough space on disk! (Free:$freespace File:$fileToBackupsize)\n"
        exit 1
}

# Check first argument only, doesn't support multiple args/modes
while [ $# -gt 0 ];
do
    case "$1" in
      -h|--help)
        echo -e "\n${bold}MC-BACKUP by Arcaniist${normal}\n---------------------------\nA compression script of\n[$fileToBackup] to [$backupLocation] for $serverName!\n"
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
      log -e "${bold}Error:${normal} Invalid argument: ${1}\n" 
      echo -e "Usage:\nNo args | Compress $serverName's root dir\n-h | Help (this)\n-w | Compress worlds only\n-r | Restart with warnings, no backups made.\n-g | Compress & upload $serverName's root dir to gdrive\n-wu | Compress & upload worlds to gdrive\n-p | Compress plugins only\n-pu | Compress & upload plugins to gdrive"      exit 1
      ;;
    esac
    shift
done

# Title, description and credits :)
echo -e "\n${bold}MC-BACKUP by Arcaniist${normal}\n---------------------------\nA compression script of\n[$fileToBackup] to [$backupLocation] for $serverName!\n"

if [ ! -d $fileToBackup ]; then
    log "${bold}Error:${normal} Server folder not found! ($fileToBackup)\n"
    exit 1
fi

if [ ! -d $backupLocation ]; then
    log "${bold}Error:${normal} Backup folder not found! ($backupLocation)\n"
    exit 1
fi

# Reports server isn't running if JAVA process isn't detected
if ! ps -e | grep -q "java"; then
    log "${bold}Warning:${normal} $serverName is not running! Continuing without in-game warnings ... \n"
    serverRunning=false
fi

if [ $screens -eq 0 ]; then
    log "${bold}Error:${normal} No screen sessions running!\n"
    exit 1
elif [ $screens -gt 1 ]; then
    log "${bold}Error:${normal} More than 1 screen session is running, am confuse!\n"
    exit 1
fi

if [ $# -gt 1 ]; then
    log -e "${bold}Error:${normal} Too many arguments!\n"
    echo -e "Usage:\nNo args | Compress $serverName's root dir\n-h | Help (this)\n-w | Compress worlds only\n-r | Restart with warnings, no backups made.\n-p | Compress plugins only\n"
    exit 1
fi

# Won't check if a backup would fit on disk if in restart only
if ! $restartOnly; then
    willitfit
fi

# Won't execute stophandling if server is offline upon script start
if $serverRunning; then
    stopHandling
fi

# Grabs date in seconds *BEFORE* compressing
elapsedTimeStart="$(date -u +%s)"

if $restartOnly; then
	log "\nRestart only on [$currentDay] ...\n"
elif $worldsOnly; then
    log "\nWorlds only started on [$currentDay] ...\n"
	# Starts the tar with files from the void so that multiple files can be looped in from array then gziped
    tar cf $backupLocation/$serverName[WORLDS]-$currentDay.tar --files-from /dev/null 
	for item in "${serverWorlds[@]}"
    do
        tar rf $backupLocation/$serverName[WORLDS]-$currentDay.tar "$fileToBackup/$item"
    done
    gzip $backupLocation/$serverName[WORLDS]-$currentDay.tar
elif $pluginOnly; then
    log "\nPlugins only started on [$currentDay] ...\n"
    tar -czPf $backupLocation/$serverName[PLUGINS]-$currentDay.tar.gz $fileToBackup/plugins
else
	log "\nFull compression started on [$currentDay] ...\n"
	tar -czPf $backupLocation/$serverName-$currentDay.tar.gz $fileToBackup
fi

# Grabs date in seconds *AFTER* compression then does math to find time it took to compress
elapsedTimeEnd="$(date -u +%s)"
elapsed="$(($elapsedTimeEnd-$elapsedTimeStart))"

# Size of entire backup directory in kb, assumes file backed up is the only thing in backup directory -- ***** caveat *****
compressedSize=$(du -sh $backupLocation* | cut -c 1-3)

# Will restart server if it was online upon script start OR if in restartonly mode regardless of server state at script launch -- therefore WONT restart server if offline upon script launch
if $serverRunning || $restartOnly; then
    screen -p 0 -X stuff "$startScript $(printf \\r)"
fi

if $restartOnly; then
    log "$serverName restarted in $((elapsed/60)) minute(s)!\n"
elif $worldsOnly; then
	log "WORLDS compressed ($compressedSize) & $serverName restarted in $((elapsed/60)) minute(s)!\n"
elif $pluginOnly; then
	log "PLUGINS compressed ($compressedSize) & $serverName restarted in $((elapsed/60)) minute(s)!\n"
else
    uncompressedSize=$(du -sh $fileToBackup* | cut -c 1-3)
    log "[$fileToBackup] ($uncompressedSize) compressed to [$backupLocation] ($compressedSize) in $((elapsed/60)) minutes!\n"
fi
exit 0
