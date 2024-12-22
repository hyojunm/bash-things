#!/usr/bin/env bash

SHORTCUT_FILE=$HOME/.shortcuts
TEMP_FILE=$HOME/.temp

list_shortcuts() {
	counter=0
	
	while read line; do
		(( counter++ ))
		readarray -d "," -t entry <<< "$line"
		echo "[${counter}] ${entry[0]}"
	done < $SHORTCUT_FILE

	if [[ counter -eq 0 ]]; then
		return 1
	fi
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

remove_shortcut() {
	target=$1
	counter=0

	# clear the temp file
	touch $TEMP_FILE
	echo -n "" > $TEMP_FILE

	while read line; do
		(( counter++ ))

		# only write if not remove target
		if [[ $counter -ne $target ]]; then
			echo $line >> $TEMP_FILE
		fi
	done < $SHORTCUT_FILE

	cat $TEMP_FILE > $SHORTCUT_FILE

	if [[ $? -eq 0 ]]; then
		echo "Removed successfully."
	fi
}

edit_shortcut() {
	target=$1
	counter=0

	new_name=$2
	new_path=$3

	# clear the temp file
	touch $TEMP_FILE
	echo -n "" > $TEMP_FILE

	while read line; do
		(( counter++ ))

		if [[ $counter -eq $target ]]; then
			readarray -d "," -t entry <<< "$line"
			
			name="${entry[0]}"
			path=$(echo ${entry[1]} | sed 's/\n//')
			
			if [[ -n $new_name ]]; then
				name="$new_name"
			fi
			
			if [[ -n $new_path ]]; then
				path="$new_path"
			fi

			echo "$name,$path" >> $TEMP_FILE
		else
			echo $line >> $TEMP_FILE
		fi
	done < $SHORTCUT_FILE

	cat $TEMP_FILE > $SHORTCUT_FILE

	if [[ $? -eq 0 ]]; then
		echo "Updated successfully."
	fi
}

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

touch $SHORTCUT_FILE

is_add=0
is_edit=0
is_help=0
is_list=0
is_remove=0

sc_name=""
sc_path=""

to_edit=0
to_remove=0

# needed to reset option flags
OPTIND=1

while getopts "ae:hln:p:r:" flag; do
	case "$flag" in
		a) is_add=1
		   ;;
		e) is_edit=1
		   to_edit=$OPTARG
		   ;;
		h) is_help=1
		   ;;
		l) is_list=1
		   ;;
		n) sc_name="$OPTARG"
		   ;;
		p) sc_path="$OPTARG"
		   ;;
		r) is_remove=1
		   to_remove=$OPTARG
		   ;;
		*) ;;
	esac
done

# cannot use more than one command flag
# https://stackoverflow.com/questions/60081399/how-to-enforce-only-the-use-of-one-flag-in-a-shell-script
if (( is_add + is_edit + is_help + is_list + is_remove > 1 )); then
	echo "You can only use one command flag at a time."
	echo "Use goto -h for help."
fi

# if no command flag was used, show the main menu
# list all shortcuts and let the user select one
if (( is_add + is_edit + is_help + is_list + is_remove == 0 )); then
	if [[ $# -eq 0 ]]; then
		list_shortcuts

		if [[ $? -eq 1 ]]; then
			echo "No shortcuts available."
			echo "Use goto -a to create a new shortcut."
			return
		fi
		
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

	# verify sc_path is a valid path on the computer

	if [[ -z $sc_name ]]; then
		sc_name=$sc_path
	fi

	add_shortcut "$sc_name" "$sc_path"
fi

# listing all shortcuts
if [[ is_list -eq 1 ]]; then
	list_shortcuts
fi

# editing a shortcut
if [[ is_edit -eq 1 ]]; then
	if [[ to_edit -eq 0 ]]; then
		echo "Please select a valid shortcut to edit."
		echo "Use goto -l to view all shortcuts."
	fi
	
	if [[ -n $sc_path ]]; then
		sc_path="$(pwd)/$sc_path"
		sc_path=$(realpath $sc_path)
	fi

	edit_shortcut $to_edit "$sc_name" "$sc_path"
fi

# removing a shortcut
if [[ is_remove -eq 1 ]]; then
	if [[ to_remove -eq 0 ]]; then
		echo "Please select a valid shortcut to delete."
		echo "Use goto -l to view all shortcuts."
	fi

	remove_shortcut $to_remove
fi
