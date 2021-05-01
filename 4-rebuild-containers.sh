#!/bin/bash

# Source: http://stackoverflow.com/a/246128
# This was accurate more than DIR_NAME=$(dirname $(readlink -f "$0"))
DIR_NAME="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd ${DIR_NAME}

# Load the configuration
. load-config.sh

sum=""
for x in $(ls -1 docker-compose-files/dcf-*.yml);do
  sum="${sum} -f ${x}"
done

container_names=""
if [ ! -z "$1" ]; then
  container_names="$@"
  echo -e "${PREFIX_COLOR_SUCCESS}Filtering the actions over the following containers ${container_names}...${SUFFIX_COLOR_DEFAULT}"
fi

echo -e "${PREFIX_COLOR_SUCCESS}Building the containers...${SUFFIX_COLOR_DEFAULT}"
# It's possible to use the depends_on parameter in docker-compose file in the proxy service to make it wait for the
#   creation of the other containers but it's hard to manage when it comes to adding and removing the container names from that parameter
#   so I opted to start all the containers except the proxy then to start the proxy to make sure all the web servers defined in the upstream directive are reachable
sudo docker-compose ${sum} --compatibility up -d --force-recreate --build ${container_names}
#sudo docker-compose -f docker-compose-common.yml --compatibility up -d --force-recreate

echo -e "${PREFIX_COLOR_SUCCESS}Creating the tasks inside the Docker containers...${SUFFIX_COLOR_DEFAULT}"
# If no container name filtering was enabled
if [ -z "${container_names}" ]; then
  # Parse the projects folders
  for i in $(find projects/* -mindepth 2 -maxdepth 2 -type d); do
    if [ -f "${i}/config.json" ]; then
      CONTAINER=$(bash -c "cd ${i} 2> /dev/null && . load-config.sh 2> /dev/null && echo -n \${CONTAINER} 2> /dev/null")
      echo -e "${PREFIX_COLOR_SUCCESS}  Container ${CONTAINER} found${SUFFIX_COLOR_DEFAULT}"
      sudo ./${i}/setup-container.sh
      echo "Status (0=OK): " $?
    fi
  done
else
  # Parse the filtered container names
  echo -e "${PREFIX_COLOR_SUCCESS}Parsing the filtered Docker containers... ${container_names}${SUFFIX_COLOR_DEFAULT}"
  # Never use double quotes here
  for c in ${container_names}; do
    container_found="0"
    # Parse the projects folders searching for the filtered containers
    for i in $(find projects/* -mindepth 2 -maxdepth 2 -type d); do
      if [ -f "${i}/config.json" ]; then
        CONTAINER=$(bash -c "cd ${i} 2> /dev/null && . load-config.sh 2> /dev/null && echo -n \${CONTAINER} 2> /dev/null")
        #if [[ ${container_names} =~ (^|[[:space:]])"${CONTAINER}"($|[[:space:]]) ]]; then
        if [ "${c}" == "${CONTAINER}" ]; then
          echo -e "${PREFIX_COLOR_SUCCESS}  Container ${CONTAINER} found${SUFFIX_COLOR_DEFAULT}"
          sudo ./${i}/setup-container.sh
          echo "Status (0=OK): " $?
          container_found="1"
        fi
      fi
    done
    if [ "${container_found}" == "0" ]; then
      echo -e "${PREFIX_COLOR_WARNING}  Container ${c} not found${SUFFIX_COLOR_DEFAULT}"
    fi
  done
fi

echo -e "${PREFIX_COLOR_SUCCESS}Recreate the containers with the tasks ready...${SUFFIX_COLOR_DEFAULT}"
sudo docker-compose ${sum} --compatibility up -d --force-recreate ${container_names}
