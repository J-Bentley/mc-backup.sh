#!/bin/bash
: '
mc-backup by J-Bentley
https://github.com/J-Bentley/mc-backup.sh'
 
serverDir="/home/jordan/minecraft-server"
backupDir="/home/jordan/minecraft-backup"
startScript="bash start.sh"
gracePeriod="1m"
serverWorlds=("world" "world_nether" "world_the_end")
# Don't change anything past this line unless you know what you're doing.
 
currentDay=$(date +"%Y-%m-%d")
currentTime=$(date +"%H:%M")
screens=$(ls /var/run/screen/S-$USER -1 | wc -l || 0) # a file is created in /var/run/screen/S-$user for every screen session
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
    # injects commands into screen via stuff to notify players, sleeps for graceperiod, stop server and sleeps for hdd spin times
    log "[$currentDay] [$currentTime] Warning players & stopping server...\n"
    screen -p 0 -X stuff "say Server is restarting in $gracePeriod!$(printf \\r)"
    sleep $gracePeriod
    screen -p 0 -X stuff "say Server is restarting now!$(printf \\r)"
    screen -p 0 -X stuff "save-all$(printf \\r)"
    sleep 5
    screen -p 0 -X stuff "stop$(printf \\r)"
    sleep 5
}
worldfoldercheck () {
    # Checks to make sure all the worlds defined in serverWorlds array exist as directories in serverDir
    for item in "${serverWorlds[@]}"
    do
        if [ ! -d $serverDir/$item ]; then
            log "[$currentDay] [$currentTime] Error: World folder not found! Backup has been cancelled. ($serverDir/$item doesnt exist)\n"
            exit 1
	fi
    done
}
 
# USER INPUT
while [ $# -gt 0 ];
do
    case "$1" in
      -h|--help)
        echo -e "\nmc-backup by J-Bentley\nA local backup script for Minecraft!"
        echo -e "\nUsage:\nNo args | Full backup\n-h | Help\n-w | Backup worlds only\n-r | Restart server with in-game warnings, no backup.\n-p | Backup plugins only.\n-pc | Backup plugin configs only."
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
      log -e "[$currentDay] [$currentTime] Error: Invalid argument: ${1}\n" 
      ;;
    esac
    shift
done
 
# Logs error and cancels script if too many args given to script
if [ $# -gt 1 ]; then
    log -e "[$currentDay] [$currentTime] Error: Too many arguments! Backup has been cancelled.\n"
    exit 1
fi
# Logs error and cancels script if serverDir isn't found
if [ ! -d $serverDir ]; then
    log "[$currentDay] [$currentTime] Error: Server folder not found! Backup has been cancelled. ($serverDir doesnt exist)\n"
    exit 1
fi
# Logs error and cancels script if backupDir isn't found
if [ ! -d $backupDir ]; then
    log "[$currentDay] [$currentTime] Error: Backup folder not found! Backup has been cancelled. ($backupDir doesnt exist)\n"
    exit 1
fi
# Logs error if java process isn't running but will continue anyways
if ! ps -e | grep -q "java"; then
    log "[$currentDay] [$currentTime] Warning: Server is not running! Continuing without in-game warnings...\n"
    serverRunning=false
fi
 # Logs error if no screen sessions or more than one are running
if [ $screens -eq 0 ]; then
    log "[$currentDay] [$currentTime] Error: No screen sessions running! Backup has been cancelled.\n"
    exit 1
elif [ $screens -gt 1 ]; then
    log "\n[$currentDay] [$currentTime] Error: More than 1 screen session is running! Backup has been cancelled.\n"
    exit 1
fi
# Wont execute stopHandling if server is offline upon script start
if $serverRunning; then
    stopHandling
fi
 
# LOGIC HANDLING
if $restartOnly; then
    log "[$currentDay] [$currentTime] Restarting server...\n"
elif $worldsOnly; then
    log "[$currentDay] [$currentTime] Worlds backup started...\n"
    # Starts the tar with files from the void (/dev/null is a symlink to a non-existent dir) so that multiple files can be looped in from array then gziped
    tar cf $backupDir/WorldBackup-$currentDay.tar --files-from /dev/null 
    for item in "${serverWorlds[@]}"
    do
        tar rf $backupDir/WorldBackup-$currentDay.tar "$serverDir/$item"
    done
    gzip $backupDir/WorldBackup-$currentDay.tar
elif $pluginOnly; then
    log "[$currentDay] [$currentTime] Plugins backup started...\n"
    tar -czPf $backupDir/PluginsBackup-$currentDay.tar.gz $serverDir/plugins
elif $pluginconfigOnly; then
    log "[$currentDay] [$currentTime] Plugin configs backup started...\n"
    tar -czPf $backupDir/PluginConfigBackup-$currentDay.tar.gz --exclude='*.jar' $serverDir/plugins
else
    log "[$currentDay] [$currentTime] Full backup started...\n"
    tar -czPf $backupDir/FullBackup-$currentDay.tar.gz $serverDir
fi

if $restartOnly; then
    : # do nothing to avoid spam
elif $worldsOnly; then
    log "[$currentDay] [$currentTime] Created world backup.\n"
elif $pluginOnly; then
    log "[$currentDay] [$currentTime] Created plugin backup.\n"
elif $pluginconfigOnly; then
    log "[$currentDay] [$currentTime] Created plugin config backup.\n"
else
    log "[$currentDay] [$currentTime] Created full backup.\n"
fi
 
# Will restart server if it was online upon script start OR if in restartOnly mode; wont restart server if it was already offline upon script launch unless restartOnly
if $serverRunning || $restartOnly; then
    screen -p 0 -X stuff "$startScript $(printf \\r)"
    log "[$currentDay] [$currentTime] Ran server start script.\n"
fi
exit 0
