#!/bin/bash
: '
MC-BACKUP
https://github.com/J-Bentley/mc-backup.sh'

serverDir="/home/jbentley/mc"
backupDir="/home/jbentley/backup"
serverName="ChiknyCraft"
startScript="bash start.sh"
gracePeriod="1m"
serverWorlds=("world" "world_nether" "world_the_end")
# Don't change anything past this line unless you know what you're doing.

currentDay=$(date +"%Y-%m-%d-%H:%M")
screens=$(ls /var/run/screen/S-$USER -1 | wc -l || 0)
serverRunning=true
worldsOnly=false
pluginOnly=false
restartOnly=false
pluginconfigOnly=false

log () {
    # Echos text passed to function and appends to file at same time
    builtin echo -e "$@" | tee -a mc-backup_log.txt
}
stopHandling () {
    # injects commands into console via stuff to warn chat of backup, sleeps for graceperiod, restarts, sleeps for hdd spin times
    log "[$currentDay] Warning players & stopping $serverName...\n"
    screen -p 0 -X stuff "say &l&2$serverName is restarting in $gracePeriod!$(printf \\r)"
    sleep $gracePeriod
    screen -p 0 -X stuff "say &l&2$serverName is restarting now!$(printf \\r)"
    screen -p 0 -X stuff "save-all$(printf \\r)"
    sleep 5
    screen -p 0 -X stuff "stop$(printf \\r)"
    sleep 5
}
worldfoldercheck () {
    # Checks to make sure all the worlds defined in serverWorlds array exist as directories
    for item in "${serverWorlds[@]}"
    do
        if [! -d $backupDir/$item ]; then
            log "[$currentDay] Error: World folder not found! ($backupDir/$item)\n"
            exit 1
	    fi
    done
}
deleteBackup () {
    # Deletes contents of backupDir at start of every execution unless restartOnly mode
    if [ "$(ls -A $backupDir)" ]; then
		log "[$currentDay] Warning: Backup directory not empty! Deleting contents before proceeding ...\n"
                rm -R $backupDir/*
		exit 1
	fi
}

# USER INPUT
while [ $# -gt 0 ];
do
    case "$1" in
      -h|--help)
        echo -e "MC-BACKUP by Arcaniist\n---------------------------\nA compression script of\n[$serverDir] to [$backupDir] for $serverName!\n"
        echo -e "Usage:\nNo args | Compress $serverName root dir.\n-h | Help (this).\n-w | Compress worlds only.\n-r | Restart with warnings, no backups made.\n-p | Compress plugins only.\n-pc | Compress plugin config files only."
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
      log -e "[$currentDay] Error: Invalid argument: ${1}\n" 
      ;;
    esac
    shift
done

# Logs error if too many args given to script
if [ $# -gt 1 ]; then
    log -e "[$currentDay] Error: Too many arguments!\n"
    exit 1
fi
# Logs error if serverDir isn't found
if [ ! -d $serverDir ]; then
    log "[$currentDay] Error: Server folder not found! ($fileToBackup)\n"
    exit 1
fi
# Logs error if backupDir isn't found
if [ ! -d $backupDir ]; then
    log "[$currentDay] Error: Backup folder not found! ($backupLocation)\n"
    exit 1
fi

# Logs error if JAVA process isn't detected
if ! ps -e | grep -q "java"; then
    log "[$currentDay] Warning: $serverName is not running! Continuing without in-game warnings...\n"
    serverRunning=false
fi

if [ $screens -eq 0 ]; then
    log "[$currentDay] Error: No screen sessions running!\n"
    exit 1
elif [ $screens -gt 1 ]; then
    log "\n[$currentDay] Error: More than 1 screen session is running!\n"
    exit 1
fi

# Deletes contents of backupDir at start of every execution unless restartOnly mode
if ! $restartOnly; then
    deleteBackup
fi

# Wont execute stopHandling if server is offline upon script start
if $serverRunning; then
    stopHandling
fi

# Grabs date in seconds BEFORE compression begins
elapsedTimeStart="$(date -u +%s)"

# LOGIC HANDLING
if $restartOnly; then
	log "[$currentDay] Restart only started ...\n"
elif $worldsOnly; then
    log "[$currentDay] Worlds only started ...\n"
	# Starts the tar with files from the void (/dev/null is a symlink to a non-existent dir) so that multiple files can be looped in from array then gziped together.
    tar cf $backupDir/$serverName[WORLDS]-$currentDay.tar --files-from /dev/null 
	for item in "${serverWorlds[@]}"
    do
        tar rf $backupDir/$serverName[WORLDS]-$currentDay.tar "$serverDir/$item"
    done
    gzip $backupDir/$serverName[WORLDS]-$currentDay.tar
elif $pluginOnly; then
    log "[$currentDay] Plugins only started...\n"
    tar -czPf $backupDir/$serverName[PLUGINS]-$currentDay.tar.gz $serverDir/plugins
elif $pluginconfigOnly; then
    log "[$currentDay] Plugin Configs only started...\n"
	tar -czPf $backupDir/$serverName[PLUGIN-CONFIG]-$currentDay.tar.gz --exclude='*.jar' $serverDir/plugins
else
	log "[$currentDay] Full compression started...\n"
	tar -czPf $backupDir/$serverName-$currentDay.tar.gz $serverDir
fi

# Grabs date in seconds AFTER compression completes then does math to find time it took to compress
elapsedTimeEnd="$(date -u +%s)"
elapsed="$(($elapsedTimeEnd-$elapsedTimeStart))"

# Grabs size of item in backuplocation, assumes compressed item is only file in dir via deletebackup function
compressedSize=$(du -sh $backupLocation* | cut -c 1-3)

# Will restart server if it was online upon script start OR if in restartonly mode regardless of server state at script launch -- therefore WONT restart server if offline upon script launch ever
if $serverRunning || $restartOnly; then
    screen -p 0 -X stuff "$startScript $(printf \\r)"
	log "[$currentDay] $startScript initialized ...\n"
fi

if $restartOnly; then
    log "[$currentDay] $serverName restarted in $((elapsed/60)) min(s)!\n"
elif $worldsOnly; then
	log "[$currentDay] $serverWorlds compressed to $compressedSize and copied to $backupDir in $((elapsed/60)) min(s)!\n"
elif $pluginOnly; then
    log "[$currentDay] $fileToBackup/plugins* compressed from $uncompressedSize to $compressedSize and copied to $backupDir in $((elapsed/60)) min(s)!\n"
elif $pluginconfigOnly; then
    log "[$currentDay] Plugin configs compressed from $uncompressedSize to $compressedSize and copied to $backupDir in $((elapsed/60)) min(s)!\n"
else
    # Grabs size of Server file in kb for comparison on output
    uncompressedSize=$(du -sh $fileToBackup* | cut -c 1-3) 
	log "[$currentDay] $fileToBackup compressed from $uncompressedSize to $compressedSize and copied to $backupDir in $((elapsed/60)) min(s)!\n"
fi
exit 0
