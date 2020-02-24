#!/bin/bash
: '
MC-BACKUP version 6.3
https://github.com/J-Bentley/mc-backup.sh '

fileToBackup="/home/me/minecraftserver"
backupLocation="/home/me/backup"
serverName="MyServer"
startScript="bash start.sh"
graceperiod="1m"
serverWorlds=("world" "world_nether" "world_the_end")

currentDay=$(date +"%Y-%m-%d-%H:%M")
screens=$(ls /var/run/screen/S-$USER -1 | wc -l || 0) # Screen stores a txt per running session, finds how many
serverRunning=true 

worldsOnly=false
pluginOnly=false
restartOnly=false
pluginconfigOnly=false

log () {
    # Echos text paseed to function and appends to file at same time
    builtin echo -e "$@" | tee -a mc-backup_log.txt
}
stopHandling () {
    log "\n[$currentDay] Warning players & stopping $serverName...\n"
    screen -p 0 -X stuff "say &l&2$serverName is restarting in $graceperiod!$(printf \\r)"
    sleep $graceperiod
    screen -p 0 -X stuff "say &l&2$serverName is restarting now!!$(printf \\r)"
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
            log "\n[$currentDay] Error: World folder not found! ($backupLocation/$item)\n"
            exit 1
	    fi
    done
}
deletebackup () {
    # Checks if anything is in backup dir, logs it then removes it
    if [ "$(ls -A $backupLocation)" ]; then
		log "\n[$currentDay] Warning: Backup directory not empty! Following files will be removed ... \n"
		log "$(ls $backupLocation)"
        rm -r $backupLocation/*
	fi
}

# Check first argument only, doesn't support multiple args/modes
while [ $# -gt 0 ];
do
    case "$1" in
      -h|--help)
        echo -e "\nMC-BACKUP by Arcaniist\n---------------------------\nA compression script of\n[$fileToBackup] to [$backupLocation] for $serverName!\n"
        echo -e "Usage:\nNo args | Compress $serverName's root dir.\n-h | Help (this).\n-w | Compress worlds only.\n-r | Restart with warnings, no backups made.\n-p | Compress plugins only.\n-pc | Compress plugin config files only."
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
	  -pc|--pluginconfig)
        pluginconfigOnly=true
        ;;
      *)
      log -e "\n[$currentDay] Error: Invalid argument: ${1}\n" 
      ;;
    esac
    shift
done

if [ $# -gt 1 ]; then
    log -e "\n[$currentDay] Error: Too many arguments!\n"
    exit 1
fi

if [ ! -d $fileToBackup ]; then
    log "\n[$currentDay] Error: Server folder not found! ($fileToBackup)\n"
    exit 1
fi

if [ ! -d $backupLocation ]; then
    log "\n[$currentDay] Error: Backup folder not found! ($backupLocation)\n"
    exit 1
fi

# Reports server isn't running if JAVA process isn't detected
if ! ps -e | grep -q "java"; then
    log "\n[$currentDay] Warning: $serverName is not running! Continuing without in-game warnings ...\n"
    serverRunning=false
fi

if [ $screens -eq 0 ]; then
    log "\n[$currentDay] Error: No screen sessions running!\n"
    exit 1
elif [ $screens -gt 1 ]; then
    log "\n[$currentDay] Error: More than 1 screen session is running, am confuse!\n"
    exit 1
fi

# wont run deletebackup function in restartonly but will otherwise
if ! $restartOnly; then
    deletebackup
fi

# Wont execute stophandling if server is offline upon script start
if $serverRunning; then
    stopHandling
fi

# Grabs date in seconds BEFORE compressing
elapsedTimeStart="$(date -u +%s)"

if $restartOnly; then
	log "\n[$currentDay] Restart only started ...\n"
elif $worldsOnly; then
    log "\n[$currentDay] Worlds only started ...\n"
	# Starts the tar with files from the void so that multiple files can be looped in from array then gziped together
    tar cf $backupLocation/$serverName[WORLDS]-$currentDay.tar --files-from /dev/null 
	for item in "${serverWorlds[@]}"
    do
        tar rf $backupLocation/$serverName[WORLDS]-$currentDay.tar "$fileToBackup/$item"
    done
    gzip $backupLocation/$serverName[WORLDS]-$currentDay.tar
elif $pluginOnly; then
    log "\n[$currentDay] Plugins only started...\n"
    tar -czPf $backupLocation/$serverName[PLUGINS]-$currentDay.tar.gz $fileToBackup/plugins
elif $pluginconfigOnly; then
    log "\n[$currentDay] Plugin Configs only started...\n"
	tar -czPf $backupLocation/$serverName[PLUGINS-CONFIGS]-$currentDay.tar.gz --exclude='*.jar' $fileToBackup/plugins
else
	log "\n[$currentDay] Full compression started...\n"
	tar -czPf $backupLocation/$serverName-$currentDay.tar.gz $fileToBackup
fi

# Grabs date in seconds AFTER compression then does math to find time it took to compress
elapsedTimeEnd="$(date -u +%s)"
elapsed="$(($elapsedTimeEnd-$elapsedTimeStart))"

# Size of entire backup directory in kb, assumes file backed up is the only thing in backup directory -- *CAVEAT*
compressedSize=$(du -sh $backupLocation* | cut -c 1-3)

# Will restart server if it was online upon script start OR if in restartonly mode regardless of server state at script launch -- therefore WONT restart server if offline upon script launch
if $serverRunning || $restartOnly; then
    screen -p 0 -X stuff "$startScript $(printf \\r)"
	log "\n[$currentDay] Start script initialized ...\n"
fi

if $restartOnly; then
    log "\n[$currentDay] $serverName restarted in $((elapsed/60)) min(s)!\n"
elif $worldsOnly; then
	log "\n[$currentDay] $serverWorlds compressed to $compressedSize and copied to $backupLocation in $((elapsed/60)) min(s)!\n"
elif $pluginOnly; then
    log "\n[$currentDay] $fileToBackup/plugins* compressed from $uncompressedSize to $compressedSize and copied to $backupLocation in $((elapsed/60)) min(s)!\n"
elif $pluginconfigOnly; then
    log "\n[$currentDay] Plugin configs compressed from $uncompressedSize to $compressedSize and copied to $backupLocation in $((elapsed/60)) min(s)!\n"
else
    uncompressedSize=$(du -sh $fileToBackup* | cut -c 1-3)
	log "\n[$currentDay] $fileToBackup compressed from $uncompressedSize to $compressedSize and copied to $backupLocation in $((elapsed/60)) min(s)!\n"
fi
exit 0
