#!/usr/bin/env bash

##############################################
# This script is required by GoCD Job in order to
# replace variables in the make file with the
# values from the GoCD Job.
##############################################
CLUSTER_NAME=""
MAKEFILE=""

# Flags to make sure all options are given
mOptionFlag=false;
cOptionFlag=false;
# Get options from the command line
while getopts ":m:c:" OPTION
do
    case $OPTION in
        m)
          mOptionFlag=true
          MAKEFILE=$OPTARG
          ;;
        c)
          cOptionFlag=true
          CLUSTER_NAME=$OPTARG
          ;;
        *)
          echo "Usage: $(basename $0) -m <Makefile location> -c <Cluster Name>"
          exit 0
          ;;
    esac
done

if ! $mOptionFlag || ! $cOptionFlag;
then
  echo "Usage: $(basename $0) -m <Makefile location>  -c <Cluster Name>"
  exit 0;
fi

# substitue whole line where string 'CLUSTER_NAME :=' appears
echo "Substituting Cluster name value: ${CLUSTER_NAME}..."
sed -i "/CLUSTER_NAME :=/c\CLUSTER_NAME := ${CLUSTER_NAME}" $MAKEFILE
