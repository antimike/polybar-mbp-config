#!/usr/bin/env bash

dir="$HOME/.config/polybar"

export DPI="$(xrdb -query | grep dpi | cut -f2)"
export HEIGHT="$((18 * DPI / 96))"
export BATTERY="$(find /sys/class/power_supply -name "BAT*" -printf '%f')"
export ADAPTER="$(find /sys/class/power_supply -name "ADP*" -printf '%f')"
export BACKLIGHT="$(ls -1 /sys/class/backlight | head -1)"
export WIFI_INTERFACE="$(ip link | grep -o 'wlp[^:]*')"

MONITORS=$(xrandr --current --listactivemonitors | sed -nE 's/ *([0-9]+): [+*]*([^ ]*).*/\2/p' | tr '\n' ' ')
PRIMARY=$(xrandr --current --listactivemonitors | sed -nE 's/ *([0-9]+): [+]?[*]([^ ]*).*/\2/p')
NMONITORS=$(echo $MONITORS | wc -w)
PRIMARY=${PRIMARY:-${MONITORS%% *}}

launch_bar() {
	# Terminate already running bar instances
	killall -q polybar

	# Wait until the processes have been shut down
	while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done


	# Launch the bar
	if [[ "$style" == "hack" || "$style" == "cuts" ]]; then
		polybar -q top -c "$dir/$style/config.ini" &
		polybar -q bottom -c "$dir/$style/config.ini" &
	elif [[ "$style" == "pwidgets" ]]; then
		bash "$dir"/pwidgets/launch.sh --main
	else
		polybar -q main -c "$dir/$style/config.ini" &	
	fi
}

help() { 
	cat <<- EOF >&2
	Usage: launch.sh --theme
		
	Available Themes:
	$(find "$dir" -maxdepth 1 -mindepth 1 -type d -printf '--%f\n')
	EOF
}

style="${1#--}"
(test -n "$style" && test -d "$dir/$style" && launch_bar "$style") || help

