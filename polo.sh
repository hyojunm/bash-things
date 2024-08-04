#!/usr/bin/env bash

polo() {
    marco=$(cat ~/.marco)
    echo "Finding Marco Polo..."
    
    if [ -d $marco ]
    then
	cd $marco
    else
	echo "Can't find Marco Polo!"
    fi
}
