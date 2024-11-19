#!/usr/bin/env bash

BASE_DIRECTORY="~"

source "${BASE_DIRECTORY}/bash-things/custom_shell_prompt.sh"
source "${BASE_DIRECTORY}/bash-things/power.sh"

export PROMPT_COMMAND="source ${BASE_DIRECTORY}/bash-things/custom_shell_prompt.sh"
