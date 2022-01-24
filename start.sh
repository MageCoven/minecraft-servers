#!/bin/bash

memory=6 # Change max RAM memory in giga bytes
file="" # Set to the file name of the server file

session="${PWD//@(*\/|[.])}" # Get current folder name, with dots removed
tmux has-session -t $session 2>/dev/null

if [$file == ""]; then
    echo "Server file not defined"
    exit 1
fi

if [$? != 0]; then
    echo "Creationg session"
    tmux new -d -s $session
    echo "Starting server"
    tmux send-keys -t $session:0 "java -Xmx${memory}G -jar ${file} --nogui" Enter
    echo "Completed Successfully"
else
    read "Server already running, would you like to attach to the session? (y/N)" yn
    case $yn in
        [Yy]* ) tmux attach -t $session;;
        *     ) exit;;
    esac
fi
