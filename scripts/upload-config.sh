#!/bin/sh -e
####################################################################
## This script uploads passed file, or folder to the `config` Bucket
####################################################################

AWS_PROFILE=${AWS_PROFILE}
CLUSTER_NAME=${CLUSTER_NAME}

echo "Getting AWS account number..."
AWS_ACCOUNT=$(aws --profile ${AWS_PROFILE} iam get-user | jq ".User.Arn" | grep -Eo '[[:digit:]]{12}')
echo $AWS_ACCOUNT

CONFIG_BUCKET=${CONFIG_BUCKET:-${CLUSTER_NAME}-config}
BUCKET_URL="s3://${AWS_ACCOUNT}-${CONFIG_BUCKET}"

# Role to be used by the instance
AWS_ROLE=$1

# shift to read all arguments except 1st
shift
# Resources (files or folders) to upload
RESOURCES=$@

for UPLOAD_RESOURCE in $RESOURCES
do
  # Extract the file name
  fname=`basename $UPLOAD_RESOURCE`

  echo $AWS_ROLE
  echo $UPLOAD_RESOURCE

  # If resource to upload is a file
  if [ -f $UPLOAD_RESOURCE ]
  then aws --profile ${AWS_PROFILE} s3 cp ${UPLOAD_RESOURCE} ${BUCKET_URL}/${AWS_ROLE}/${fname}
  # else if resource to upload is a folder
  elif [ -d $UPLOAD_RESOURCE ]
  then aws --profile ${AWS_PROFILE} s3 cp --recursive ${UPLOAD_RESOURCE} ${BUCKET_URL}/${AWS_ROLE}/${fname}
  fi
done