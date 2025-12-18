#!/usr/bin/env bash
set -Eeuo pipefail

serverDir="/home/arcaniist/Minecraft-server"
backupDir="/home/arcaniist/Minecraft-backup"
startScript="bash start.sh"
gracePeriod="1m"
serverWorlds=("world" "world_nether" "world_the_end")
# Don't change anything past this line unless you know what you're doing.

timeStamp=$((date +"%Y-%m-%d_%H-%M-%S")
screens=$(screen -ls | grep -c "$USER")
serverRunning=true
worldsOnly=false
pluginOnly=false
restartOnly=false
pluginConfigOnly=false
fullBackup=false
 
log () {
    builtin echo -e "$@" | tee -a "mc-backup_log.txt"
}

stopHandling () {
    log "$timeStamp Warning players and stopping server..."
    screen -p 0 -X stuff "say The server is restarting in $gracePeriod.$(printf \\r)"
    sleep $gracePeriod
    screen -p 0 -X stuff "say The server is restarting now.$(printf \\r)"
    screen -p 0 -X stuff "save-all$(printf \\r)"
    sleep 5
    screen -p 0 -X stuff "stop$(printf \\r)"
    sleep 5
}

worldFolderCheck () {
    for item in "${serverWorlds[@]}"
    do
        if [ ! -d "$serverDir/$item" ]; then
            log "$timeStamp Error: World folder not found! Backup has been cancelled. ("$serverDir/$item" doesnt exist)\n"
            exit 3
	    fi
    done
}

# Input handling

if [ $# -gt 1 ]; then
    log -e "$timeStamp Error: Too many arguments! Backup has been cancelled.\n"
    exit 2
fi

if [ $# -eq 0 ]; then
    echo -e "\nmc-backup\nA local backup script for Minecraft servers."
    echo -e "\nUsage:"
    echo "-f  | Full backup"
    echo "-w  | Backup worlds only"
    echo "-r  | Restart server only"
    echo "-p  | Backup plugins only"
    echo "-pc | Backup plugin configs only"
    exit 0
fi

while [ $# -gt 0 ];
do
    case "$1" in
      -f|--fullbackup)
		log "$timeStamp Full backup started."
		fullBackup=true;
        ;;
      -w|--worlds)
        log "$timeStamp Worlds backup started."
        worldsOnly=true
        ;;
      -p|--plugin)
        log "$timeStamp Plugins backup started."
        pluginOnly=true
        ;;
      -r|--restart)
        log "$timeStamp Restarting server."
        restartOnly=true
        ;;
      -pc|--pluginconfig)
        log "$timeStamp Plugin configs backup started."
        pluginConfigOnly=true
        ;;
      *)
      log -e "$timeStamp Error: Invalid argument! (${1}) Backup has been cancelled.\n"
      exit 2
      ;;
    esac
    shift
done

# Error handling

[[ -d "$serverDir" ]] || { log "$timeStamp Error: Server folder not found! Backup has been cancelled.\n"; exit 3; }
[[ -d "$backupDir" ]] || { log "$timeStamp Error: Backup folder not found! Backup has been cancelled.\n"; exit 3; }

if ! pgrep -f java > /dev/null; then
    log "$timeStamp Warning: Server is not running!"
    serverRunning=false
fi

if [ $screens -eq 0 ]; then
    log "$timeStamp Error: No screen sessions running! Backup has been cancelled.\n"
    exit 1
elif [ $screens -gt 1 ]; then
    log "$timeStamp Error: More than one screen session running! Backup has been cancelled.\n"
    exit 1
fi

# Shutdown Handling

if $serverRunning; then
    stopHandling
fi

# Backup Operations

if $restartOnly; then
    :
elif $worldsOnly; then
    worldFolderCheck
    tar -czPf "$backupDir/$timeStamp-WorldsBackup.tar.gz" \
        "${serverWorlds[@]/#/$serverDir/}"
    log "$timeStamp Created world backup."
elif $pluginOnly; then
    tar -czPf "$backupDir/$timeStamp-PluginsBackup.tar.gz" "$serverDir/plugins"
    log "$timeStamp Created plugins backup."
elif $pluginConfigOnly; then
    tar -czPf "$backupDir/$timeStamp-PluginConfigsBackup.tar.gz" --exclude='*.jar' "$serverDir/plugins"
    log "$timeStamp Created plugin configs backup."
elif $fullBackup; then
    tar -czPf "$backupDir/$timeStamp-FullBackup.tar.gz" "$serverDir"
    log "$timeStamp Created full backup."
fi
 
# Restart Handling

if $serverRunning || $restartOnly; then
    screen -p 0 -X stuff "$startScript $(printf \\r)"
    log "$timeStamp Ran server start script.\n"
fi

exit 0
