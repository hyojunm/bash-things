#!/usr/bin/env bash

SHORTCUT_FILE=~/.shortcuts

list_shortcuts() {
	counter=1
	
	while read line; do
		readarray -d "," -t entry <<< "$line"
		echo "[${counter}] ${entry[0]}"
		(( counter++ ))
	done < $SHORTCUT_FILE
}

shortcut_exists() {
	target_index=0
	target_value=$2
	
	case $1 in
		# searching by shortcut name 
		n) target_index=0 ;;
		
		# searching by shortcut path
		p) target_index=1 ;;

		# searching by shortcut index
		i) target_index=2 ;;
	esac

	counter=1
	found=0

	while read line; do
		readarray -d "," -t entry <<< "$line"

		# if searching by index and current counter value equals target
		# then shortcut exists
		[[ $target_index -eq 2 ]] && [[ $target_value -eq $counter ]] && found=1 && break

		written_value=$(echo ${entry[$target_index]} | sed 's/\n//')

		# if searching by name or path and entry value equals target
		# then shortcut exists
		[[ $written_value = $target_value ]] && found=1 && break

		(( counter++ ))
	done < $SHORTCUT_FILE

	echo $found
}

add_shortcut() {
	name=$1
	path=$2

	if [[ "$(shortcut_exists n $name)" -eq 1 ]]; then
		echo "Shortcut name already exists."
		return
	fi
	
	if [[ "$(shortcut_exists p $path)" -eq 1 ]]; then
		echo "Shortcut path already exists."
		return
	fi
	
	echo "$name,$path" >> $SHORTCUT_FILE

	if [[ $? -eq 0 ]]; then
		echo "Added successfully."
	fi
}

# remove_shortcut() {

# }

# edit_shortcut() {

# }

find_shortcut() {
	target=$1
	counter=1

	while read line; do
		readarray -d "," -t entry <<< "$line"

		if [[ $counter -eq $target ]]; then
			# remove newline character from path string
			target_path=$(echo ${entry[1]} | sed 's/\n//')

			cd $target_path
			return
		fi
		
		(( counter++ ))
	done < $SHORTCUT_FILE
}

goto_main_menu() {
	echo "Available shortcuts:"
	list_shortcuts

	echo
	echo -n "Enter shortcut number ('q' to cancel): "

	read selection

	([[ -z $selection ]] || [[ $selection = "q" ]]) && return

	if [[ $(shortcut_exists i $selection) -eq 1 ]]; then
		find_shortcut $selection
	else
		echo
		echo "This shortcut option does not exist."
		echo "Use goto -l to view all shortcuts."
	fi
}

touch $SHORTCUT_FILE

is_add=0
is_edit=0
is_help=0
is_list=0

sc_name=""
sc_path=""

# needed to reset option flags
OPTIND=1

while getopts "aehln:p:" flag; do
	case "$flag" in
		a) is_add=1 ;;
		e) is_edit=1 ;;
		h) is_help=1 ;;
		l) is_list=1 ;;
		n) sc_name=$OPTARG ;;
		p) sc_path=$OPTARG ;;
		*) ;;
	esac
done

# cannot use more than one command flag
# https://stackoverflow.com/questions/60081399/how-to-enforce-only-the-use-of-one-flag-in-a-shell-script
if (( is_add + is_edit + is_help + is_list > 1 )); then
	echo "wtf are you tryna do"
fi

# if no command flag was used, show the main menu
# list all shortcuts and let the user select one
if (( is_add + is_edit + is_help + is_list == 0 )); then
	if [[ $# -eq 0 ]]; then
		list_shortcuts
		
		echo
		echo "Type in a number, or press 'Enter' to cancel."
		echo -n ">>> "
		
		read selection
	else
		selection=$1
	fi

	if [[ -n $selection ]]; then
		if [[ $(shortcut_exists i $selection) -eq 1 ]]; then
			find_shortcut $selection
		else
			if [[ $# -eq 0 ]]; then
				echo
			fi

			echo "This shortcut does not exist."
			echo "Use goto -l to view all shortcuts."
		fi
	fi
fi

# adding a shortcut
# default path = current directory
# default name = path
if [[ is_add -eq 1 ]]; then
	cwd=$(pwd)
	
	if [[ -n $sc_path ]]; then
		sc_path="$cwd/$sc_path"
	else
		sc_path=$cwd
	fi

	sc_path=$(realpath $sc_path)

	if [[ -z $sc_name ]]; then
		sc_name=$sc_path
	fi

	add_shortcut $sc_name $sc_path
fi

# listing all shortcuts
if [[ is_list -eq 1 ]]; then
	list_shortcuts
fi

#################################
#  TO-DO                        #
# ----------------------------- #
#  * add edit function          #
#  * add remove function        #
#  * add help function          #
#  * what if comma is part of   #
#    path?                      #
#  * when using -n flag, input  #
#    could be multiple words    #
#################################
