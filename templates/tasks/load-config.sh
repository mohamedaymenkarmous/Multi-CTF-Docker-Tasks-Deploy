#!/bin/bash

# Source: http://stackoverflow.com/a/246128
# This was accurate more than DIR_NAME=$(dirname $(readlink -f "$0"))
DIR_NAME="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd ${DIR_NAME}


export PREFIX_COLOR_SUCCESS="\e[38;5;82m"
export PREFIX_COLOR_WARNING="\e[38;5;202m"
export PREFIX_COLOR_ERROR="\e[31m"
export SUFFIX_COLOR_DEFAULT="\e[39m"

function exit_on_missing_config(){
  if [ ! -f "config.json" ]; then
    echo -e "${PREFIX_COLOR_ERROR}Please make sure to create config.json file and to configure it before creating any container${SUFFIX_COLOR_DEFAULT}"
    echo -e "${PREFIX_COLOR_ERROR}cp config.json.template config.json${SUFFIX_COLOR_DEFAULT}"
    exit 1
  fi
}
exit_on_missing_config

function parse_config(){
  default="$1"
  shift;
  params="$@"
  attrs=""
  for i in ${params}; do
    attrs="${attrs}[${i}]"
  done
  echo -n $(cat config.json 2> /dev/null | python3 -c "import json,sys;print(json.load(sys.stdin)${attrs})" 2> /dev/null || echo $default)
}
function parse_config_n(){
  default="$1"
  shift;
  params="$@"
  attrs=""
  for i in ${params}; do
    attrs="${attrs}[${i}]"
  done
  echo -n $(cat config.json 2> /dev/null | python3 -c "import json,sys;print(len(json.load(sys.stdin)${attrs}))" 2> /dev/null || echo $default)
}

export PREFIX=$(parse_config '' "'prefix'")
export TYPE=$(parse_config '' "'type'")
export ID=$(parse_config '' "'id'")

export CONTAINER="${PREFIX}${TYPE}${ID}"

function valid_container_name(){
  if [ -z "${CONTAINER}" ]; then
    echo -e "${PREFIX_COLOR_ERROR}Please make sure that you've defined the container name in the config.json file${SUFFIX_COLOR_DEFAULT}"
    echo -e "${PREFIX_COLOR_ERROR}Knowing that container=prefix+type+id${SUFFIX_COLOR_DEFAULT}"
    echo -e "${PREFIX_COLOR_ERROR}You can take a look at config.json.template as an example${SUFFIX_COLOR_DEFAULT}"
    exit 1
  fi
}
valid_container_name

export PREFIX_COLOR_SUCCESS="\e[38;5;82m### [$CONTAINER] "

export ENABLED=$(parse_config '0' "'enabled'")
export ENABLED_TASKS=$(parse_config '' "'enabled_tasks'")
export DISABLED_TASKS=$(parse_config '' "'disabled_tasks'")
export ROOT_PATH=$(parse_config '/root' "'root_path'")

function exit_on_disabled(){
  if [ "${ENABLED}" != "1" ]; then
    echo -e "${PREFIX_COLOR_WARNING}Container ${CONTAINER} is disabled. If you want to enable it, you need to do that in its config.json file${SUFFIX_COLOR_DEFAULT}"
    exit 0
  fi
}
