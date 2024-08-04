#!/usr/bin/env bash

export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DISPLAY=:0

notify-send -a "Institute for Computing in Research" \
	    -t 5000 -i ./studying-hard.png \
	    "Friendly Reminder" \
	    "It is $(date +"%I:%M %p")! Time to go home :D"

# Note: "studying-hard.png" must be in the same directory as this script!
