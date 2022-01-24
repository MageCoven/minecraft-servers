#!/bin/bash

folders=()

function parse_config_file {
    if [ ! -f "start.config" ]; then
        echo "ERROR: ${folder:-"Current folder"} lacks a start.config file"
        exit 1
    fi

    grep "^(file=.*\.jar)" start.config
    if [ $? != 0 ]; then
        echo "ERROR: start.config either does not have a `file` field or it is incorrectly initialized"
    fi

    grep "^(memory=[1-9][0-9]*)" start.config
    if [ $? != 0 ]; then
        echo "ERROR: start.config either does not have a `memory` field or it is incorrectly initialized"
    fi

    source start.config
}

for arg in "$@"; do
    case $arg in
        * )
            folders+=("$1")
            shift
    esac
done

if [ ${#folders[*]} == 0 ]; then
    echo "No folders provided"
    exit 1
fi

for folder in $folders; do
    if [ ! -d $folder ]; then
        echo "ERROR: ${folder} does not exist"
        exit 1
    fi

    tmux has-session -t "${folder//@([.]|[\/])}" 2>/dev/null
    if [ $? != 0 ]; then
        echo "ERROR: Server ${folder//@([.]|[\/])} already running"
        continue
    fi

    (
        cd $folder

        parse_config_file

        echo "Creating tmux session ${folder//@([.]|[\/])}"
        tmux new -d -s "${folder//@(*\/|[.])}"
        if [ $? =! 0 ]; then
            echo "ERROR: Tmux exited abnormally with exit code $?"
            exit 1
        fi
        echo "Sending start command to server"
        tmux send-keys -t "${folder//@([.]|[\/])}":0 "java -Xmx${memory}G -jar $file --nogui" Enter
        echo "Done"
    )
done