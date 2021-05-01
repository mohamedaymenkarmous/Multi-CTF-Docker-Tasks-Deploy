#!/bin/bash

# Source: http://stackoverflow.com/a/246128
# This was accurate more than DIR_NAME=$(dirname $(readlink -f "$0"))
DIR_NAME="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd ${DIR_NAME}

# Load the configuration
. load-config.sh

if [ ! -f ".setup_done" ]; then
  ${PWD}/1-setup-docker.sh
  echo "1"> .setup_done
fi

container_names=""
if [ ! -z "$1" ]; then
  container_names="$@"
fi

echo -e "${PREFIX_COLOR_SUCCESS}Creating docker-compose files...${SUFFIX_COLOR_DEFAULT}"
${PWD}/2-create-new-projects-docker.sh
echo -e "${PREFIX_COLOR_SUCCESS}Creating new projects...${SUFFIX_COLOR_DEFAULT}"
${PWD}/2-create-new-projects-nginx.sh
echo -e "${PREFIX_COLOR_SUCCESS}Generating TLS certificates...${SUFFIX_COLOR_DEFAULT}"
${PWD}/3-init-letsencrypt.sh
echo -e "${PREFIX_COLOR_SUCCESS}Building the containers...${SUFFIX_COLOR_DEFAULT}"
${PWD}/4-rebuild-containers.sh ${container_names}
echo -e "${PREFIX_COLOR_SUCCESS}Restart the tasks inside the containers...${SUFFIX_COLOR_DEFAULT}"
${PWD}/5-restart-tasks.sh ${container_names}
