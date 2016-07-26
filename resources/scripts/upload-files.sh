# If number of command line arguments supplied is less than 2
if [ "$#" -lt 2 ]; then
    echo "Illegal number of arguments"
		echo "Usage: $(basename $0) <path to dir from which the files are to be uploaded> <destination path in s3 config bucket>"
		exit 0
fi

if [ ! -d $1 ]; then
  echo "First argument must be a directory"
  exit 0
fi

# Get instance auth token from meta-data
get_value() {
  echo -n $(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/$roleProfile/ \
      | grep "$1" \
      | awk -F":" '{print $2}' \
      | sed 's/^[ ^t]*//;s/"//g;s/,//g')
}

# Headers for curl
create_string_to_sign() {
  contentType="application/x-compressed-tar"
  contentType=""
  dateValue="`date +'%a, %d %b %Y %H:%M:%S %z'`"

  # stringToSign
  stringToSign="PUT

${contentType}
${dateValue}
x-amz-security-token:${s3Token}
${resource}"
}

DOWNLOADED=false;
download_file_to_check() {
  tempDir="/etc/temp_reg"
  mkdir -p ${tempDir}
  regCertFile="CLUSTER-NAME_docker_registry/registry_certificates/ca.pem"

  resource="/${configBucket}/${regCertFile}"
  create_string_to_sign
  signature=$(/bin/echo -n "$stringToSign" | openssl sha1 -hmac ${s3Secret} -binary | base64)
  debug_log
  curl -s -L -O -H "Host: ${configBucket}.s3.amazonaws.com" \
    -H "Content-Type: ${contentType}" \
    -H "Authorization: AWS ${s3Key}:${signature}" \
    -H "x-amz-security-token:${s3Token}" \
    -H "Date: ${dateValue}" \
    https://${configBucket}.s3.amazonaws.com/${regCertFile}

  # if ca.pem file is downloaded and is a valid certificate copy to docker registry certificate location
  # else delete the downloaded files
  if [ -f ${tempDir}/ca.pem ] && grep -q "BEGIN CERTIFICATE" ${tempDir}/ca.pem ;
  then
    DOWNLOADED=true;
  else
    DOWNLOADED=false;
  fi
  rm -f ${tempDir}
}
# Instance profile
roleProfile=$(curl -s http://169.254.169.254/latest/meta-data/iam/info \
        | grep -Eo 'instance-profile/([a-zA-Z0-9._-]+)' \
        | sed  's#instance-profile/##')

# AWS Account
accountId=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document \
        | grep -Eo '([[:digit:]]{12})')

# Bucket path to upload certificates to
configBucket=${accountId}-CLUSTER-NAME-config

# Find token, AccessKeyId,  line, remove leading space, quote, commas
s3Token=$(get_value "Token")
s3Key=$(get_value "AccessKeyId")
s3Secret=$(get_value "SecretAccessKey")

source_location=$1

for file in ${source_location}/*
do
  fileName=${file##*/}
  echo "Uploading ${fileName} ..."
  registry_certificates="${roleProfile}/$2/${fileName}"
  resource="/${configBucket}/${registry_certificates}"
  create_string_to_sign
  signature=$(/bin/echo -n "$stringToSign" | openssl sha1 -hmac ${s3Secret} -binary | base64)

  #Retry if file not uploaded
  retry=5
  ready=0
  until [[ $retry -eq 0 ]]  || [[ $ready -eq 1  ]]
  do
    curl -X PUT -T "${file}" \
    -H "Host: ${configBucket}.s3.amazonaws.com" \
    -H "Date: ${dateValue}" \
    -H "Content-Type: ${contentType}" \
    -H "Authorization: AWS ${s3Key}:${signature}" \
    -H "x-amz-security-token:${s3Token}" \
    https://${configBucket}.s3.amazonaws.com/${registry_certificates}

    # Download file to check if exists or not
    download_file_to_check
    if [[ DOWNLOADED -eq true ]];
    then
      ready=1
      echo "File: $file Uploaded Successfully ..."
    else
      let "retry--"
      echo "File: $file not uploaded, retrying ..."
    fi;
  done
done