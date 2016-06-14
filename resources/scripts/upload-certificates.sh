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

# Instance profile
roleProfile=$(curl -s http://169.254.169.254/latest/meta-data/iam/info \
        | grep -Eo 'instance-profile/([a-zA-Z0-9._-]+)' \
        | sed  's#instance-profile/##')

# AWS Account
accountId=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document \
        | grep -Eo '([[:digit:]]{12})')

# Bucket path to upload certificates to
configBucket=${accountId}-coreos-cluster-config

# Find token, AccessKeyId,  line, remove leading space, quote, commas
s3Token=$(get_value "Token")
s3Key=$(get_value "AccessKeyId")
s3Secret=$(get_value "SecretAccessKey")

certificates_location="/opt/registry/ssl"

for file in ${certificates_location}/*
do
  fileName=${file##*/}
  echo "Uploading ${fileName} ..."
  registry_certificates="${roleProfile}/registry_certificates/${fileName}"

  resource="/${configBucket}/${registry_certificates}"
  create_string_to_sign
  signature=$(/bin/echo -n "$stringToSign" | openssl sha1 -hmac ${s3Secret} -binary | base64)

  curl -X PUT -T "${file}" \
  -H "Host: ${configBucket}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  -H "x-amz-security-token:${s3Token}" \
  https://${configBucket}.s3.amazonaws.com/${registry_certificates}
done
