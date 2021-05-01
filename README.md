# Multi-CTF-Tasks-Deploy
Repository to deploy multiple CTF tasks instances using docker.

You can create multiple CTF instances hosted on the same server automatically.

## Configuration

Every Docker container is defined by a single folder under `projects/[PREFIX]/[TYPE]/[ID]/`. For the time being you need to manually create that folders tree and then you copy `templates/tasks/*` inside `projects/[PREFIX]/[TYPE]/[ID]/`.

There are 2 configuration files:

- `docker-compose-files/dcf-[YOUR_CUSTOM_CTF_NAME].yml`: This file will define the docker containers that will be created. You can check an example in
[docker-compose-files/dcf-example.yml.example](docker-compose-files/dcf-example.yml.example). You can create your own files or you can rename that file and use it on your own way.
- `config.json`: This file will define the reverse proxy configuration. This is mainly used to serve HTTP(S) requests. If you'll need this feature, you have to copy `config.json.example` to `config.json` and edit it on your own way.

After you create the container's project inside `projects/[PREFIX]/[TYPE]/[ID]/` using `templates/tasks` template, you need to edit the following files based on your need:

- Copy `projects/[PREFIX]/[TYPE]/[ID]/config.json.example` to `projects/[PREFIX]/[TYPE]/[ID]/config.json` and edit it.
- Define the global system initialization needed for the Docker container inside `projects/[PREFIX]/[TYPE]/[ID]/setup/init.sh`.
- Create the setup tasks folders inside `projects/[PREFIX]/[TYPE]/[ID]/setup/setup-task/` and create the script `projects/[PREFIX]/[TYPE]/[ID]/setup/setup-task/{taskX}/task.sh` that will define how the task should be setup (including the system initialization for that particular task).
- Create the setup exception folders inside `projects/[PREFIX]/[TYPE]/[ID]/setup/setup-exception/` and create the script `projects/[PREFIX]/[TYPE]/[ID]/setup/setup-exception/{taskX}/task.sh` that will apply some updates that were previously overrided by the automatic setup (the permissions for example).
- Edit the `projects/[PREFIX]/[TYPE]/[ID]/sbin/restart-services.sh` script and add the commands used to restart the global services
- Create the task restart folders inside `projects/[PREFIX]/[TYPE]/[ID]/sbin/` and create the script `projects/[PREFIX]/[TYPE]/[ID]/sbin/{taskX}/restart.sh` that will be used to restart a specific task using the root permissions (similar to `projects/[PREFIX]/[TYPE]/[ID]/sbin/restart-services.sh`).
- Create the task restart folders inside `projects/[PREFIX]/[TYPE]/[ID]/bin/` and create the script `projects/[PREFIX]/[TYPE]/[ID]/bin/{taskX}/restart.sh` that will be used to restart a specific task using the task user permissions


## Features

- [x] Multiple tasks per Docker container
- [x] Multiple Docker containers (using `docker-compose`)
- [x] Defined project template (from `templates/tasks`)
- [ ] Automated Docker container projects creation (for the time being this is done manually inside `projects/[PREFIX]/[TYPE]/[ID]/` from the project template `templates/tasks`)
- [x] Automated Docker containers setup
  - [x] Configurable Docker containers using Dockerfile (inside `projects/[PREFIX]/[TYPE]/[ID]/`)
  - [x] Configurable Docker containers using docker-compose files globally (inside `docker-compose-files/dcf-*.yml`)
  - [ ] Defined docker-compose template
    - [x] docker-compose template for the reverse proxy and certbot (inside `dcf-docker-compose-common.yml`)
    - [ ] docker-compose template for the tasks (defined as an example instead `docker-compose-files/dcf-example.yml.example` but it's not included in the automation as it should be included from `templates` directory)
  - [x] Automated system initialization
  - [x] Automated system initialization (using `1-setup-docker.sh`)
  - [x] Automated docker-compose files creation (using `2-create-new-projects-docker.sh`)
    - [x] docker-compose file for the reverse proxy and certbot (using the template `docker-compose-common-template.yml`)
    - [ ] docker-compose file for the tasks (manually created based on `docker-compose-files/dcf-example.yml.example`)
  - [x] Automated nginx files creation (using `2-create-new-projects-nginx.sh`)
    - [x] For the virtual hosts that are mapping the traffic to the reverse proxy and certbot
    - [x] For the virtual hosts that are mapping the traffic to the tasks
  - [x] Automated TLS certificate creation using certbot (using `3-init-letsencrypt.sh`)
    - [x] Configurable creation (using `config.json`)
    - [x] Renewal only when the service is running (protection against renewal exhaustion)
    - [x] Old certificates backup every renewal
    - [ ] Disable email registration once its done
  - [x] Automated TLS certificates renewal (using `4-renew-certificates.sh`)
    - [ ] Scheduled renewal
  - [x] Automated Docker containers rebuild (using `4-rebuild-containers.sh`)
    - [x] Docker container rebuild
    - [x] Tasks setup within the Docker container (using `projects/[PREFIX]/[TYPE]/[ID]/setup-container.sh`)
      - [x] Start the Docker container
      - [x] Initialize the system inside the Docker container
        - [x] Cutomizable system initialization (using `projects/[PREFIX]/[TYPE]/[ID]/setup/init.sh`)
      - [x] Setup the tasks (using `projects/[PREFIX]/[TYPE]/[ID]/setup/setup-task.sh`)
        - [x] Cutomizable tasks setup (using `projects/[PREFIX]/[TYPE]/[ID]/setup/setup-task/{taskX}/task.sh`)
      - [x] Setup the tasks (using `projects/[PREFIX]/[TYPE]/[ID]/setup/setup-task.sh`)
        - [x] Cutomizable tasks setup (using `projects/[PREFIX]/[TYPE]/[ID]/setup/setup-task/{taskX}/task.sh`)
      - [x] Permissions updates (using `projects/[PREFIX]/[TYPE]/[ID]/setup-container.sh`)
        - [ ] Cutomizable permissions updates (using `projects/[PREFIX]/[TYPE]/[ID]/config.json`)
      - [x] Exceptions setup (using `projects/[PREFIX]/[TYPE]/[ID]/setup/setup-exception.sh`)
        - [x] Cutomizable tasks setup (using `projects/[PREFIX]/[TYPE]/[ID]/setup/setup-exception/{taskX}/task.sh`)
      - [x] Docker container persistence (using `docker commit`)
        - [ ] Customizable Docker container persistence (using `projects/[PREFIX]/[TYPE]/[ID]/config.json`)
    - [x] Selective container rebuild (using the script parameters)
    - [x] Granular restart of the setup steps
      - [x] When the script is killed (due to a lack of RAM)
      - [x] Custom number of restarts (fixed to 3)
        - [ ] Configurable number of restarts (using `projects/[PREFIX]/[TYPE]/[ID]/config.json`)
  - [x] Automated Docker containers redeployment (using `4-redeploy-containers.sh`)
    - [x] Selective container redeployment (using the script parameters)
  - [x] Automated containers stop (using `4-stop-containers.sh`)
    - [x] Selective container stop (using the script parameters)
  - [x] Automated tasks restart (using `5-restart-tasks.sh`)
    - [x] Restart the tasks within the Docker container (using `projects/[PREFIX]/[TYPE]/[ID]/restart-tasks.sh`)
      - [x] Start the Docker container
      - [x] Restart the global services using the root permissions (using `projects/[PREFIX]/[TYPE]/[ID]/sbin/restart-services.sh`)
        - [x] Customizable restart (still using `projects/[PREFIX]/[TYPE]/[ID]/sbin/restart-services.sh`)
      - [x] Restart the tasks individually using the root permissions (using `projects/[PREFIX]/[TYPE]/[ID]/sbin/{taskX}/restart.sh`)
        - [x] Customizable restart (still using `projects/[PREFIX]/[TYPE]/[ID]/sbin/{taskX}/restart.sh`)
      - [x] Restart the tasks individually using the non-root permissions (using `projects/[PREFIX]/[TYPE]/[ID]/bin/{taskX}/restart.sh`)
        - [x] Customizable restart (still using `projects/[PREFIX]/[TYPE]/[ID]/bin/{taskX}/restart.sh`)
        - [ ] Restart using custom user (using `projects/[PREFIX]/[TYPE]/[ID]/config.json`)
    - [x] Selective containers that will have their tasks restarted (using the script parameters)
    - [ ] Selective restarted tasks (using the script parameters)
    - [ ] Selective enabled/disabled tasks (using `projects/[PREFIX]/[TYPE]/[ID]/config.json`)

### Project structure
To be done



### Example
To be done
