# https://www.gnu.org/software/bash/manual/html_node/Controlling-the-Prompt.html

REGULAR="\e[0m"
BOLD="\e[1m"
#DIM="\e[2m"
UNDERLINE="\e[4m"

DEFAULT="\e[39m"
RED="\e[31m"
GREEN="\e[32m"
MAGENTA="\e[35m"
CYAN="\e[36m"
GRAY="\e[90m"
LIGHT_RED_BACK="\e[101m"
LIGHT_YELLOW_BACK="\e[103m"

# red=31;green=32;yellow=33;blue=34;magenta=35;cyan=36;gray=90;

# https://stackoverflow.com/questions/2111042/how-to-get-the-name-of-the-current-git-branch-into-a-variable-in-a-shell-script
BRANCH=$(git symbolic-ref --short HEAD 2> /dev/null)

if [ $? -ne 0 ]
then
    BRANCH=""
fi

if [[ $BRANCH = "main" ]]
then
    BRANCH="$GREEN$BRANCH"
fi

PS0="🖥️  "

PS1="${debian_chroot:+($debian_chroot)}\n"

LINE1=""
LINE2=""
LINE3=""

LINE1+="$REGULAR$LIGHT_RED_BACK\D{%D %H:%M}"

if [[ $BRANCH != "" ]]
then
    LINE1+="$REGULAR$DEFAULT ${LIGHT_YELLOW_BACK}branch: $UNDERLINE$BRANCH"
fi

LINE1+="$REGULAR$DEFAULT\n"

LINE2+="$REGULAR$BOLD$CYAN\u"
LINE2+="$REGULAR$DEFAULT @ "

CURRENT_DIRECTORY=$(pwd)

# echo ${#CURRENT_DIRECTORY}
# echo $((COLUMNS-10))

while [ ${#CURRENT_DIRECTORY} -ge $((COLUMNS - 15)) ]
do
    CURRENT_DIRECTORY=$(echo $CURRENT_DIRECTORY | cut -d "/" -f 2-)
done

if [ $CURRENT_DIRECTORY != $(pwd) ]
then
    CURRENT_DIRECTORY=".../$CURRENT_DIRECTORY"
fi

LINE2+="$REGULAR$UNDERLINE$MAGENTA$CURRENT_DIRECTORY"
LINE3+="$REGULAR$DEFAULT\n👦 "

PS1+=$LINE1$LINE2$LINE3

# try doing some spell check stuff?
# what if there is no output?
