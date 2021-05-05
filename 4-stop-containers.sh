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

echo -e "${PREFIX_COLOR_SUCCESS}Stopping containers...${SUFFIX_COLOR_DEFAULT}"
#sudo docker stop $(sudo docker ps -a -q)
sudo docker-compose ${sum} stop ${container_names}

