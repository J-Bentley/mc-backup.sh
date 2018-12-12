#!/bin/bash
# Uses "stuff" to inject strings into the input buffer of a running window.
# Says a warning in-game, saves worlds, stops server & compresses backup.

screen -p 0 -X stuff "say Treescape restarting in 2 mins!$(printf \\r)"
sleep 2m

screen -p 0 -X stuff "save-all$(printf \\r)"
sleep 5

screen -p 0 -X stuff "stop$(printf \\r)"
sleep 10

current_day=$(date +"%m_%d_%Y")
tar -czPf treescape-$current_day.tar.gz /home/jordan/treescape/
# Compress /treescape/ & save it to working directory [?] (Make it save to /backup/)

screen -p 0 -X stuff "bash start.sh$(printf \\r)"
# Restart server (not sure if will work)
