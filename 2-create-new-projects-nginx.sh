#!/bin/bash

# Source: http://stackoverflow.com/a/246128
# This was accurate more than DIR_NAME=$(dirname $(readlink -f "$0"))
DIR_NAME="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd ${DIR_NAME}

# Load the configuration
. load-config.sh || exit 1
exit_on_missing_config

if [ "$N_PROJECTS" == "0" ]; then
  echo -e "${PREFIX_COLOR_WARNING}Skipped because there was no defined project in config.json file${SUFFIX_COLOR_DEFAULT}"
  exit 0
fi

for i in $(seq 1 $N_PROJECTS);do
  name=$(parse_config '' "'projects'" "${i}-1" "'name'")
  target=$(parse_config '' "'projects'" "${i}-1" "'target'")
  hostname=$(parse_config '' "'projects'" "${i}-1" "'hostname'")
  generic_hostname=$(parse_config '' "'projects'" "${i}-1" "'generic-hostname'")
  internal_port=$(parse_config '' "'projects'" "${i}-1" "'internal-port'")
  default_server=$(parse_config '' "'projects'" "${i}-1" "'default-server'")
  deferred_server=$(parse_config '' "'projects'" "${i}-1" "'deferred-server'")
  tls_enabled=$(parse_config '' "'projects'" "${i}-1" "'tls-enabled'")
  if [ "$tls_enabled" == "1" ]; then
    sed "s/REPLACED_NAME/${name}/g" <templates/nginx-vhost-template-https.conf > nginx/sites-enabled/${name}.conf.tmp;
    sed "s/REPLACED_TARGET/${target}/g" <nginx/sites-enabled/${name}.conf.tmp > nginx/sites-enabled/${name}.conf;
    sed "s/REPLACED_HOSTNAME/${hostname}/g" <nginx/sites-enabled/${name}.conf > nginx/sites-enabled/${name}.conf.tmp;
    sed "s/REPLACED_INTERNAL_PORT/${internal_port}/g" <nginx/sites-enabled/${name}.conf.tmp > nginx/sites-enabled/${name}.conf;
    sed "s/REPLACED_HOSTNAME/${generic_hostname}/g" <templates/nginx-snakeoil-template.conf > nginx/snippets/snakeoil-${name}.conf
    if [ "$default_server" == "1" ]; then
      sed "s/REPLACED_DEFAULT_SERVER/default/g" <nginx/sites-enabled/${name}.conf > nginx/sites-enabled/${name}.conf.tmp;
    else
      sed "s/REPLACED_DEFAULT_SERVER//g" <nginx/sites-enabled/${name}.conf > nginx/sites-enabled/${name}.conf.tmp;
    fi
    if [ "$deferred_server" == "1" ]; then
      sed "s/REPLACED_DEFERRED_SERVER/deferred/g" <nginx/sites-enabled/${name}.conf.tmp > nginx/sites-enabled/${name}.conf;
    else
      sed "s/REPLACED_DEFERRED_SERVER//g" <nginx/sites-enabled/${name}.conf.tmp > nginx/sites-enabled/${name}.conf;
    fi
    rm nginx/sites-enabled/${name}.conf.tmp;
  else
    sed "s/REPLACED_NAME/${name}/g" <templates/nginx-vhost-template-http.conf > nginx/sites-enabled/${name}.conf.tmp;
    sed "s/REPLACED_TARGET/${target}/g" <nginx/sites-enabled/${name}.conf.tmp > nginx/sites-enabled/${name}.conf;
    sed "s/REPLACED_HOSTNAME/${hostname}/g" <nginx/sites-enabled/${name}.conf > nginx/sites-enabled/${name}.conf.tmp;
    sed "s/REPLACED_INTERNAL_PORT/${internal_port}/g" <nginx/sites-enabled/${name}.conf.tmp > nginx/sites-enabled/${name}.conf;
    if [ "$default_server" == "1" ]; then
      sed "s/REPLACED_DEFAULT_SERVER/default/g" <nginx/sites-enabled/${name}.conf > nginx/sites-enabled/${name}.conf.tmp;
    else
      sed "s/REPLACED_DEFAULT_SERVER//g" <nginx/sites-enabled/${name}.conf > nginx/sites-enabled/${name}.conf.tmp;
    fi
    if [ "$deferred_server" == "1" ]; then
      sed "s/REPLACED_DEFERRED_SERVER/deferred/g" <nginx/sites-enabled/${name}.conf.tmp > nginx/sites-enabled/${name}.conf;
    else
      sed "s/REPLACED_DEFERRED_SERVER//g" <nginx/sites-enabled/${name}.conf.tmp > nginx/sites-enabled/${name}.conf;
    fi
    rm nginx/sites-enabled/${name}.conf.tmp;
  fi
done
