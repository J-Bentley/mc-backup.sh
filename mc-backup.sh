#!/bin/bash
: '
mc-backup by J-Bentley
https://github.com/J-Bentley/mc-backup.sh
Read the readme on github for setup, usage and how to automate.'
 
serverDir="/home/jordan/Minecraft-server"
backupDir="/home/jordan/Minecraft-backup"
startScript="bash start.sh"
gracePeriod="1m"
serverWorlds=("world" "world_nether" "world_the_end")
# Don't change anything past this line unless you know what you're doing.

timeStamp=$(date +"[%Y-%m-%d-%H-%M]")
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
    log "$timeStamp Warning players and stopping server..."
    screen -p 0 -X stuff "say The server is restarting in $gracePeriod.$(printf \\r)"
    sleep $gracePeriod
    screen -p 0 -X stuff "say The server is restarting now.$(printf \\r)"
    screen -p 0 -X stuff "save-all$(printf \\r)"
    sleep 5
    screen -p 0 -X stuff "stop$(printf \\r)"
    sleep 5
}
worldfolderCheck () {
    # Checks to make sure all the worlds defined in serverWorlds array exist as directories in serverDir
    for item in "${serverWorlds[@]}"
    do
        if [ ! -d $serverDir/$item ]; then
            log "$timeStamp Error: World folder not found! Backup has been cancelled. ($serverDir/$item doesnt exist)\n"
            exit 1
	    fi
    done
}

if [ $# -gt 1 ]; then
    log -e "$timeStamp Error: Too many arguments! Backup has been cancelled.\n"
    exit 1
fi

if [ $# -eq 0 ]; then
    log "$timeStamp Full backup started."
fi

while [ $# -gt 0 ];
do
    case "$1" in
      -h|--help)
        echo -e "\nmc-backup by J-Bentley\nA local backup script for Minecraft servers!"
        echo -e "\nUsage:\nNo args | Full backup\n-h | Help\n-w | Backup worlds only\n-r | Restart server with in-game warnings, no backup.\n-p | Backup plugins only.\n-pc | Backup plugin configs only.\n"
        exit 0
        ;;
      -w|--worlds)
        log "$timeStamp Worlds backup started."
        worldfolderCheck
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
        pluginconfigOnly=true
        ;;
      *)
      log -e "$timeStamp Error: Invalid argument! (${1}) Backup has been cancelled.\n"
      exit 1
      ;;
    esac
    shift
done
 
# Logs error and cancels script if serverDir isn't found
if [ ! -d $serverDir ]; then
    log "$timeStamp Error: Server folder not found! Backup has been cancelled. ($serverDir doesnt exist)\n"
    exit 1
fi
# Logs error and cancels script if backupDir isn't found
if [ ! -d $backupDir ]; then
    log "$timeStamp Error: Backup folder not found! Backup has been cancelled. ($backupDir doesnt exist)\n"
    exit 1
fi
# Logs error if java process (server) isn't running but will continue anyways
if ! ps -e | grep -q "java"; then
    log "$timeStamp Warning: Server is not running! Continuing anyways..."
    serverRunning=false
fi
# Logs error if no screen sessions or more than one are running
if [ $screens -eq 0 ]; then
    log "$timeStamp Error: No screen sessions running! Backup has been cancelled.\n"
    exit 1
elif [ $screens -gt 1 ]; then
    log "$timeStamp Error: More than 1 screen session is running! Backup has been cancelled.\n"
    exit 1
fi

# Wont warn players and stop server if the server is already offline upon script launch
if $serverRunning; then
    stopHandling
fi
 
if $restartOnly; then
    :
elif $worldsOnly; then
    # Starts the tar with files from the void (/dev/null is a symlink to a non-existent dir) so that multiple files can be looped in from array then gziped
    tar cf $backupDir/$timeStamp-WorldsBackup.tar --files-from /dev/null 
    for item in "${serverWorlds[@]}"
    do
        tar rf $backupDir/$timeStamp-WorldsBackup.tar "$serverDir/$item" &> /dev/null # Mutes tar output
    done
    gzip $backupDir/$timeStamp-WorldsBackup.tar
    log "$timeStamp Created world backup."
elif $pluginOnly; then
    tar -czPf $backupDir/$timeStamp-PluginsBackup.tar.gz $serverDir/plugins
    log "$timeStamp Created plugins backup."
elif $pluginconfigOnly; then
    tar -czPf $backupDir/$timeStamp-PluginConfigsBackup.tar.gz --exclude='*.jar' $serverDir/plugins
    log "$timeStamp Created plugin configs backup."
else
    tar -czPf $backupDir/$timeStamp-FullBackup.tar.gz $serverDir
    log "$timeStamp Created full backup."
fi
 
# If the server was offline upon script launch, WONT restart it UNLESS in restartOnly mode
if $serverRunning || $restartOnly; then
    screen -p 0 -X stuff "$startScript $(printf \\r)"
    log "$timeStamp Ran server start script.\n"
fi
exit 0
