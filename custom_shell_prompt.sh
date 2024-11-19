#!/usr/bin/env bash
# https://www.gnu.org/software/bash/manual/html_node/Controlling-the-Prompt.html

# font weight/decoration
REGULAR="\e[0m"
BOLD="\e[1m"
UNDERLINE="\e[4m"

# font foreground color
DEFAULT="\e[39m"
RED="\e[31m"
GREEN="\e[32m"
MAGENTA="\e[35m"
CYAN="\e[36m"
GRAY="\e[90m"

# font background color
LIGHT_RED_BACK="\e[101m"
LIGHT_YELLOW_BACK="\e[103m"

# get current branch (if inside git repository)
get_branch() {
	# https://stackoverflow.com/questions/2111042/how-to-get-the-name-of-the-current-git-branch-into-a-variable-in-a-shell-script
	branch=$(git symbolic-ref --short HEAD 2> /dev/null)
	
	if [ $? -ne 0 ]; then
		branch=""
	fi
	
	if [[ $branch = "main" || $branch = "master" ]]; then
		branch="$GREEN$branch"
	elif [[ $branch != "" ]]; then
		branch="$GRAY$branch"
	fi

	echo $branch
}

# format the current directory string based on window size
# replace parent directories with "..." if not enough space
format_dir() {
	curr_dir="$(pwd)"

	while [ "${#curr_dir}" -ge $((COLUMNS - 15)) ]; do
		curr_dir=$(echo $curr_dir | cut -d "/" -f 2-)
	done

	if [[ $curr_dir != $(pwd) ]]; then
		curr_dir=".../$curr_dir"
	fi

	echo $curr_dir
}

# set prompt text
PS0=""
PS1="${debian_chroot:+($debian_chroot)}\n"

# show date and time
PS1+="$REGULAR$LIGHT_RED_BACK\D{%D %H:%M}" # \D = date

# show branch (if any)
branch=$(get_branch)

if [[ $branch != "" ]]; then
	PS1+="$REGULAR$DEFAULT ${LIGHT_YELLOW_BACK}"
	PS1+="branch: $UNDERLINE$BOLD$branch"
fi

# show username
PS1+="$REGULAR$DEFAULT\n"
PS1+="$REGULAR$BOLD$CYAN\u" # \u = username
PS1+="$REGULAR$DEFAULT @ "

# show directory
PS1+="$REGULAR$UNDERLINE$MAGENTA$(format_dir)"

# show prompt
PS1+="$REGULAR$DEFAULT\n> "
