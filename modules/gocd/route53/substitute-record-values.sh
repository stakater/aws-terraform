#!/usr/bin/env bash
##################################
## This file substitues
## <#RECORD_IP#> & <#RECORD_NAME#>
## in the given file.
##################################

RECORD_IP=""
RECORD_NAME=""
ACTION=""
FILE=""

# Flags to make sure all required options are given
iOptionFlag=false;
nOptionFlag=false;
fOptionFlag=false;
aOptionFlag=false;

# Get options from the command line
while getopts ":f:i:n:a:" OPTION
do
    case $OPTION in
        f)
          fOptionFlag=true
          FILE=$OPTARG
          ;;
        i)
          iOptionFlag=true
          RECORD_IP=$OPTARG
          ;;
        n)
          nOptionFlag=true
          RECORD_NAME=$OPTARG
          ;;
        a)
          aOptionFlag=true
          ACTION=$OPTARG
          ;;
        *)
          echo "Usage: $(basename $0) -f <File location> -i <Record IP> -n <Record Name> -a <Action> (DELETE, CREATE, UPDATE)"
          exit 0
          ;;
    esac
done

if ! $fOptionFlag || ! $iOptionFlag || ! $nOptionFlag || ! $aOptionFlag;
then
  echo "Usage: $(basename $0) -f <File location> -i <Record IP> -n <Record Name> -a <Action> (DELETE, CREATE, UPDATE)"
  exit 0;
fi

# create a new file tf file without the .tmpl extension
newFile="${FILE%%.tmpl*}"
cp $FILE $newFile

perl -p -i -e "s|<#RECORD_IP#>|$RECORD_IP|g" "$newFile"
perl -p -i -e "s|<#RECORD_NAME#>|$RECORD_NAME|g" "$newFile"
perl -p -i -e "s|<#ACTION#>|$ACTION|g" "$newFile"