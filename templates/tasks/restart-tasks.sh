#!/bin/bash

# Source: http://stackoverflow.com/a/246128
# This was accurate more than DIR_NAME=$(dirname $(readlink -f "$0"))
DIR_NAME="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd ${DIR_NAME}

# Load the configuration
. load-config.sh || exit 1
exit_on_disabled

echo -e "${PREFIX_COLOR_SUCCESS}Start the Docker container...${SUFFIX_COLOR_DEFAULT}"
sudo docker start ${CONTAINER}

echo -e "${PREFIX_COLOR_SUCCESS}Starting the tasks global services...${SUFFIX_COLOR_DEFAULT}"
sudo docker exec --user root ${CONTAINER} ${ROOT_PATH}/sbin/restart-services.sh

echo -e "${PREFIX_COLOR_SUCCESS}Start the tasks individually with the root permissions...${SUFFIX_COLOR_DEFAULT}"
for user in $(sudo find ${PWD}/sbin/* -mindepth 0 -maxdepth 0 -type d -exec basename {} \; 2> /dev/null);do
  restart_task=$(sudo ls ${PWD}/sbin/${user}/restart.sh ${user} 2> /dev/null)
  if [ "${restart_task}" != "" ]; then
    echo -e "${PREFIX_COLOR_SUCCESS}[${user}] Start the tasks with the root permissions...${SUFFIX_COLOR_DEFAULT}"
    sudo docker exec --user root ${CONTAINER} ${ROOT_PATH}/sbin/${user}/restart.sh ${user}
  fi
done

# Start the individual services
echo -e "${PREFIX_COLOR_SUCCESS}Start the tasks individually with the user permissions...${SUFFIX_COLOR_DEFAULT}"
for user in $(sudo find ${PWD}/bin/* -mindepth 0 -maxdepth 0 -type d -exec basename {} \; 2> /dev/null);do
  restart_task=$(sudo ls ${PWD}/bin/${user}/restart.sh ${user} 2> /dev/null)
  if [ "${restart_task}" != "" ]; then
    echo -e "${PREFIX_COLOR_SUCCESS}[${user}] Start the tasks with the ${user} user permissions...${SUFFIX_COLOR_DEFAULT}"
    sudo docker exec --user ${user} --workdir /home/${user} ${CONTAINER} /opt/bin/${user}/restart.sh ${user}
  fi
done

