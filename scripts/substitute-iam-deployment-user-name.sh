#!/usr/bin/env bash

##############################################
# This script is required by GoCD Job in order to
# replace deployment user variable in the given file
# with the values from the GoCD Job.
##############################################
DEPLOYMENT_USER=""
FILE=""

# Flags to make sure all options are given
fOptionFlag=false;
dOptionFlag=false;
# Get options from the command line
while getopts ":f:d:" OPTION
do
    case $OPTION in
        f)
          fOptionFlag=true
          FILE=$OPTARG
          ;;
        d)
          dOptionFlag=true
          DEPLOYMENT_USER=$OPTARG
          ;;
        *)
          echo "Usage: $(basename $0) -f <File location> -d <Deployment user name>"
          exit 0
          ;;
    esac
done

if ! $fOptionFlag || ! $dOptionFlag;
then
  echo "Usage: $(basename $0) -f <File location> -d <Deployment user name>"
  exit 0;
fi

# substitue whole line where string 'deployment_user =' appears
echo "Substituting DEPLOYMENT USER value: ${DEPLOYMENT_USER}..."
sed -i "/deployment_user =/c\deployment_user = \"${DEPLOYMENT_USER}\"" $FILE