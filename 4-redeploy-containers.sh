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

echo -e "${PREFIX_COLOR_SUCCESS}Creating docker-compose files...${SUFFIX_COLOR_DEFAULT}"
${PWD}/2-create-new-projects-docker.sh
echo -e "${PREFIX_COLOR_SUCCESS}Creating new projects...${SUFFIX_COLOR_DEFAULT}"
${PWD}/2-create-new-projects-nginx.sh
echo -e "${PREFIX_COLOR_SUCCESS}Generating TLS certificates...${SUFFIX_COLOR_DEFAULT}"
${PWD}/3-init-letsencrypt.sh
echo -e "${PREFIX_COLOR_SUCCESS}Redeploy the containers...${SUFFIX_COLOR_DEFAULT}"
# It's possible to use the depends_on parameter in docker-compose file in the proxy service to make it wait for the
#   creation of the other containers but it's hard to manage when it comes to adding and removing the container names from that parameter
#   so I opted to start all the containers except the proxy then to start the proxy to make sure all the web servers defined in the upstream directive are reachable
sudo docker-compose ${sum} --compatibility up -d --force-recreate ${container_names}
