#!/usr/bin/env bash

power() {
    curr=$(cat /sys/class/power_supply/BAT0/charge_now)
    #echo $curr

    full=$(cat /sys/class/power_supply/BAT0/charge_full)
    #echo $full

    pct=$((($curr*100+50)/$full))
    #echo $pct

    output="Battery remaining: $pct%"
    echo $output
}
