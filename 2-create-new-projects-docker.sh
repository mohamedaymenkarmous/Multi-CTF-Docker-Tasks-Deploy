#!/bin/bash

# Source: http://stackoverflow.com/a/246128
# This was accurate more than DIR_NAME=$(dirname $(readlink -f "$0"))
DIR_NAME="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd ${DIR_NAME}

echo -e "${PREFIX_COLOR_SUCCESS}Creating docker-compose file: docker-compose-files/dcf-docker-compose-common.yml...${SUFFIX_COLOR_DEFAULT}"
sed "s;REPLACED_FULL_PATH;${PWD};g" <${PWD}/templates/docker-compose-common-template.yml > ${PWD}/docker-compose-files/dcf-docker-compose-common.yml
