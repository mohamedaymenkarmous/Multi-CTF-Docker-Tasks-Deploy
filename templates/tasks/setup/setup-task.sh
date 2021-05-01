#!/bin/bash

PREFIX_COLOR_SUCCESS="\e[38;5;82m#### "
PREFIX_COLOR_WARNING="\e[38;5;202m"
PREFIX_COLOR_ERROR="\e[31m"
SUFFIX_COLOR_DEFAULT="\e[39m"
MAX_RETRY_START_KILLED_PROCESS="3"

if [ ! -z "$1" ]; then
  PREFIX_COLOR_SUCCESS="${PREFIX_COLOR_SUCCESS}[${1}] "
  PREFIX_COLOR_WARNING="${PREFIX_COLOR_WARNING}[${1}] "
  PREFIX_COLOR_ERROR="${PREFIX_COLOR_ERROR}[${1}] "
fi

function run_and_monitor_command(){
  command=$1
  terminated_proc="0"
  while [[ ! -z "$killed" && "$terminated_proc" -lt "${MAX_RETRY_START_KILLED_PROCESS}" ]] || [[ -z "$killed" && "$terminated_proc" -eq "0" ]]; do
    # When the process is killed it could affect the packages that are being installed using dpkg
    dpkg --configure -a
    eval $command |tee /root/std-${user}.out
    killed=$(grep -Po "\d+ Killed" /root/std-${user}.out)
    rm /root/std-${user}.out
    terminated_proc=$(expr $terminated_proc + 1)
    if [ ! -z "$killed" ]; then
      echo  -e "${PREFIX_COLOR_WARNING}[$user] Killed process inside ${command}${SUFFIX_COLOR_DEFAULT}"
      if [ "$terminated_proc" -lt "${MAX_RETRY_START_KILLED_PROCESS}" ]; then
        echo  -e "${PREFIX_COLOR_WARNING}[$user] Restarting ${command} (${terminated_proc}/`expr ${MAX_RETRY_START_KILLED_PROCESS} - 1`)...${SUFFIX_COLOR_DEFAULT}"
      else
        echo  -e "${PREFIX_COLOR_ERROR}[$user] Unabled to start ${command}. Skipped${SUFFIX_COLOR_DEFAULT}"
      fi
    fi
  done
}

function setupSingleTask {
  user=$1

  # Choose the default user shell
  echo -e "${PREFIX_COLOR_SUCCESS}[$user] Defining the user's shell...${SUFFIX_COLOR_DEFAULT}"
  shell=$(ls /home/${user}/shell.sh 2> /dev/null)
  if [ "$shell" != "" ]; then
    shell=/home/${user}/shell.sh
  else
    shell=/bin/bash
  fi

  # Create the user with a pseudo-random password
  echo -e "${PREFIX_COLOR_SUCCESS}[$user] Creating the task's users...${SUFFIX_COLOR_DEFAULT}"
  rand1=$(cat /dev/urandom | tr -dc 'A-Za-z0-9\.\!\?\*\-_\+/' | fold -w 64 | head -n 1)
  rand2=$(cat /dev/urandom | tr -dc 'A-Za-z0-9\.\!\?\*\-_\+/' | fold -w 64 | head -n 1)
  if ! id "${user}" >/dev/null 2>&1; then
    useradd -d /home/${user}/ -p "${user}${rand1}" -s ${shell} ${user}
    echo "${user}:${user}${rand1}" | chpasswd
  fi
  if ! id "r_${user}" >/dev/null 2>&1; then
    useradd -d /home/${user}/ -p "${user}${rand1}${rand2}" -s /bin/bash r_${user}
    echo "r_${user}:${user}${rand1}${rand2}" | chpasswd
  fi

  # Setup the task
  echo -e "${PREFIX_COLOR_SUCCESS}[$user] Setting up the task...${SUFFIX_COLOR_DEFAULT}"
  make_task=$(ls /root/setup/setup-task/${user}/task.sh 2> /dev/null)
  if [ "${make_task}" != "" ]; then
    # setup the individual task and capture the stdout and stderr
    run_and_monitor_command "/root/setup/setup-task/${user}/task.sh ${user} 2>&1"
  fi

  echo -e "${PREFIX_COLOR_SUCCESS}[$user] Building the task...${SUFFIX_COLOR_DEFAULT}"
  built=$(ls /root/build/${user}/ 2> /dev/null)
  if [ "${built}" != "" ]; then
    chown -R r_${user}:r_${user} /root/build/${user}/
  fi
}


echo -e "${PREFIX_COLOR_SUCCESS}Setup tasks individually...${SUFFIX_COLOR_DEFAULT}"
for user in $(find /home/* -mindepth 0 -maxdepth 0 -type d -exec basename {} \;);do
  setupSingleTask ${user}
done

