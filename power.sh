#!/usr/bin/env bash

power() {
	# current battery charge
    curr=$(cat /sys/class/power_supply/BAT0/charge_now)

	# full battery charge
    full=$(cat /sys/class/power_supply/BAT0/charge_full)

	# calculate percentage
    pct=$((( $curr * 100 + 50 ) / $full ))

    echo "Battery remaining: $pct%"
}
