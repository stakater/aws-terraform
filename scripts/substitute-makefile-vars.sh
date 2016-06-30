#!/usr/bin/env bash

##############################################
# This script is required by GoCD Job in order to
# replace variables in the make file with the
# values from the GoCD Job.
##############################################

DOCKER_IMAGE=""
DOCKER_OPTS=""
CLUSTER_NAME=""
MAKEFILE=""

# Flags to make sure all options are given
mOptionFlag=false;
iOptionFlag=false;
oOptionFlag=false;
cOptionFlag=false;
# Get options from the command line
while getopts ":m:i:o:c" OPTION
do
    case $OPTION in
        m)
          mOptionFlag=true
          MAKEFILE=$OPTARG
          ;;
        i)
          iOptionFlag=true
          DOCKER_IMAGE=$OPTARG
          ;;
        o)
          oOptionFlag=true
          DOCKER_OPTS=$OPTARG
          ;;
        c)
          cOptionFlag=true
          CLUSTER_NAME=$OPTARG
          ;;
        *)
          echo "Usage: $(basename $0) -m <Makefile location> -i <Base App Docker Image> -o <Docker Options> -c <Cluster Name>"
          exit 0
          ;;
    esac
done

if !$mOptionFlag || ! $iOptionFlag || ! $oOptionFlag || ! $cOptionFlag;
then
  echo "Usage: $(basename $0) -m <Makefile location> -i <Base App Docker Image> -o <Docker Options> -c <Cluster Name>"
  exit 0;
fi

# substitue whole line where string 'BASE_APP_DOCKER_IMG' appears
makeFile="../Makefile"
sed -i "/BASE_APP_DOCKER_IMG/c\BASE_APP_DOCKER_IMG := \\${DOCKER_IMAGE}" $MAKEFILE
sed -i "/BASE_APP_DOCKER_OPTS/c\BASE_APP_DOCKER_OPTS := \\${DOCKER_OPTS}" $MAKEFILE
sed -i "/CLUSTER_NAME/c\CLUSTER_NAME := \\${CLUSTER_NAME}" $MAKEFILE
