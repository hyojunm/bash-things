#!/usr/bin/env bash

marco() {
    pwd > ~/.marco
    whereismarco
}

whereismarco() {
    marco=$(cat ~/.marco)
    
    if [ -d $marco ]
    then
	echo "Marco Polo is located at $marco"
    else
	echo "Can't find Marco Polo!"
    fi
}
