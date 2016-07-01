#!/usr/bin/env bash

# Replace DOCKER_IMAGE and DOCKER_OPTS with
# values from environment variables
DOCKER_IMAGE=${APP_DOCKER_IMAGE}
DOCKER_OPTS=${APP_DOCKER_OPTS}

#TODO: ChECK IF ENV VARIABLES EMPTY, EXIT WITH ERROR MESSAGE

files=$(grep -s -l -e \<#DOCKER_IMAGE#\> -e \<#DOCKER_OPTS#\> -r $@)
if [ "X$files" != "X" ];
then
  for f in $files
  do
    perl -p -i -e "s|<#DOCKER_IMAGE#>|$DOCKER_IMAGE|g" $f
    perl -p -i -e "s|<#DOCKER_OPTS#>|$DOCKER_OPTS|g" $f
  done
fi
