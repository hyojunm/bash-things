#!/usr/bin/env bash

BASE_DIRECTORY="~/bash-things"

source "${BASE_DIRECTORY}/custom_shell_prompt.sh"
source "${BASE_DIRECTORY}/power.sh"
alias goto=". ${BASE_DIRECTORY}/shortcuts.sh"

export PROMPT_COMMAND="source ${BASE_DIRECTORY}/custom_shell_prompt.sh"
