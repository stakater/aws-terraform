#!/usr/bin/env bash

##############################################
# This script is required by GoCD Job in order to
# replace variables in the make file with the
# values from the GoCD Job.
##############################################

DOCKER_IMAGE=""
DOCKER_OPTS=""

# Flags to make sure both options are given
iOptionFlag=false;
oOptionFlag=false;
# Get options from the command line
while getopts ":i:o:" OPTION
do
    case $OPTION in
        i)
          iOptionFlag=true
          DOCKER_IMAGE=$OPTARG
          ;;
        o)
          oOptionFlag=true
          DOCKER_OPTS=$OPTARG
          ;;
        *)
          echo "Usage: $(basename $0) -i <Base App Docker Image> -o <Docker Options>"
          exit 0
          ;;
    esac
done

if ! $iOptionFlag || ! $oOptionFlag;
then
  echo "Usage: $(basename $0) -i <Base App Docker Image> -o <Docker Options>"
  exit 0;
fi

# substitue whole line where string 'BASE_APP_DOCKER_IMG' appears
makeFile="../Makefile"
sed -i "/BASE_APP_DOCKER_IMG/c\BASE_APP_DOCKER_IMG := \\${DOCKER_IMAGE}" $makeFile
sed -i "/BASE_APP_DOCKER_OPTS/c\BASE_APP_DOCKER_OPTS := \\${DOCKER_OPTS}" $makeFile