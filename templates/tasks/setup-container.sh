#!/bin/bash

# Source: http://stackoverflow.com/a/246128
# This was accurate more than DIR_NAME=$(dirname $(readlink -f "$0"))
DIR_NAME="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd ${DIR_NAME}

# Load the configuration
. load-config.sh || exit 1
exit_on_disabled

echo -e "${PREFIX_COLOR_SUCCESS} Start the Docker container...${SUFFIX_COLOR_DEFAULT}"
sudo docker start ${CONTAINER}

echo -e "${PREFIX_COLOR_SUCCESS}Updating the common folder's permissions...${SUFFIX_COLOR_DEFAULT}"
# Home directory permission
sudo chmod 755 ${PWD}/home 2> /dev/null
# Home directory owner
sudo chown root:root ${PWD}/home 2> /dev/null
# Home directory folders permissions (no recursive)
sudo chmod 750 ${PWD}/home/* 2> /dev/null
# Bin folder's owner
sudo chown root:root ${PWD}/bin 2> /dev/null
# Bin folder's folders permission
sudo chmod 750 ${PWD}/bin/* 2> /dev/null
# Setup folder's owner (recursive)
sudo chown root:root ${PWD}/setup -R 2> /dev/null
# Build folder's owner
sudo chown root:root ${PWD}/build 2> /dev/null
# Init script permission
sudo chmod 740 ${PWD}/setup/init.sh 2> /dev/null
# Task setup script permission
sudo chmod 740 ${PWD}/setup/setup-task.sh 2> /dev/null
# Task setup exception script permission
sudo chmod 740 ${PWD}/setup/setup-exception.sh 2> /dev/null
# Sbin folder's permission (recursive)
sudo chown 740 ${PWD}/sbin -R 2> /dev/null
# Sbin folder's owner (recursive)
sudo chown root:root ${PWD}/sbin -R 2> /dev/null

echo -e "${PREFIX_COLOR_SUCCESS}System initialization...${SUFFIX_COLOR_DEFAULT}"
sudo docker exec --user root ${CONTAINER} ${ROOT_PATH}/setup/init.sh

echo -e "${PREFIX_COLOR_SUCCESS}Updating the files permissions...${SUFFIX_COLOR_DEFAULT}"
for user in $(sudo find ${PWD}/setup/setup-task/* -mindepth 0 -maxdepth 0 -type d -exec basename {} \; 2> /dev/null);do
  setup_task=$(sudo ls ${PWD}/setup/setup-task/${user}/task.sh 2> /dev/null)
  if [ "$setup_task" != "" ]; then
    sudo chmod 750 ${PWD}/setup/setup-task/${user}/task.sh 2> /dev/null
  fi
done
for user in $(sudo find ${PWD}/setup/setup-exception/* -mindepth 0 -maxdepth 0 -type d -exec basename {} \; 2> /dev/null);do
  setup_exception=$(sudo ls ${PWD}/setup/setup-exception/${user}/task.sh 2> /dev/null)
  if [ "$setup_exception" != "" ]; then
    sudo chmod 750 ${PWD}/setup/setup-exception/${user}/task.sh 2> /dev/null
  fi
done
for user in $(sudo find ${PWD}/sbin/* -mindepth 0 -maxdepth 0 -type d -exec basename {} \; 2> /dev/null);do
  sbin=$(sudo ls ${PWD}/sbin/${user}/* 2> /dev/null)
  if [ "$sbin" != "" ]; then
    sudo chmod 750 ${PWD}/sbin/${user}/* 2> /dev/null
  fi
done
for user in $(sudo find ${PWD}/bin/* -mindepth 0 -maxdepth 0 -type d -exec basename {} \; 2> /dev/null);do
  bin=$(sudo ls ${PWD}/bin/${user}/* 2> /dev/null)
  if [ "$bin" != "" ]; then
    sudo chmod 750 ${PWD}/bin/${user}/* 2> /dev/null
  fi
done
echo -e "${PREFIX_COLOR_SUCCESS}Setup tasks...${SUFFIX_COLOR_DEFAULT}"
sudo docker exec --user root ${CONTAINER} ${ROOT_PATH}/setup/setup-task.sh "${CONTAINER}"

echo -e "${PREFIX_COLOR_SUCCESS}Copying the built files to the tasks directories...${SUFFIX_COLOR_DEFAULT}"
for user in $(sudo find ${PWD}/build/* -mindepth 0 -maxdepth 0 -type d -exec basename {} \; 2> /dev/null);do
  make_task=$(sudo ls -A ${PWD}/build/${user}/ 2> /dev/null)
  if [ "${make_task}" != "" ]; then
    sudo cp -a ${PWD}/build/${user}/* ${PWD}/home/${user}/ 2> /dev/null
  fi
done

echo -e "${PREFIX_COLOR_SUCCESS}Updating the folders owners...${SUFFIX_COLOR_DEFAULT}"
for user in $(find ${PWD}/home/* -mindepth 0 -maxdepth 0 -type d -exec basename {} \; 2> /dev/null);do
  uid=$(sudo docker exec --user root ${CONTAINER} id -u ${user})
  r_uid=$(sudo docker exec --user root ${CONTAINER} id -u r_${user})
  sudo chown ${r_uid}:${uid} ${PWD}/home/${user} -R 2> /dev/null
  sudo chown ${r_uid}:${uid} ${PWD}/bin/${user} -R 2> /dev/null
  sudo chown ${uid}:${uid} ${PWD}/tmp/${user} -R 2> /dev/null
done

# Post container setup
echo -e "${PREFIX_COLOR_SUCCESS}Global setup exception...${SUFFIX_COLOR_DEFAULT}"
chmod 750 ${PWD}/setup/setup-exception.sh
${PWD}/setup/setup-exception.sh

echo -e "${PREFIX_COLOR_SUCCESS}Setup exception by task...${SUFFIX_COLOR_DEFAULT}"
for user in $(find ${PWD}/setup/setup-exception/* -mindepth 0 -maxdepth 0 -type d -exec basename {} \; 2> /dev/null);do
  chmod 750 ${PWD}/setup/setup-exception/${user}/task.sh
  ${PWD}/setup/setup-exception/${user}/task.sh ${user}
done

echo -e "${PREFIX_COLOR_SUCCESS}Commit the new Docker container's image...${SUFFIX_COLOR_DEFAULT}"
sudo docker commit ${CONTAINER} ${CONTAINER}
