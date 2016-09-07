#!/bin/bash -e

# This is a CLUSTER-NAME-cloudinit bootstrap script. It is passed in as 'user-data' file during the machine build.
# Then the script is excecuted to download the CoreOs "cloud-config.yaml" file  and "intial-cluster" files.
# These files  will configure the system to join the CoreOS cluster. The second stage cloud-config.yaml can
# be changed to allow system configuration changes wihtout having to rebuild the system. All it takes is a reboot.
# If this script changes, the machine will need to be rebuild (user-data change)

# Convention:
# 1. A bucket should exist that contains role-based cloud-config.yaml
#  e.g. <account-id>-CLUSTER-NAME-cloudinit/<roleProfile>/cloud-config.yaml
# 2. All machines should have instance role profile, with a policy that allows readonly access to this bucket.

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
  stringToSign="GET

${contentType}
${dateValue}
x-amz-security-token:${s3Token}
${resource}"
}

# Log curl call
debug_log () {
    echo ""  >> /tmp/s3-bootstrap.log
    echo "curl -s -O -H \"Host: ${bucket}.s3.amazonaws.com\"
  -H \"Content-Type: ${contentType}\"
	-H \"Authorization: AWS ${s3Key}:${signature}\"
	-H \"x-amz-security-token:${s3Token}\"
	-H \"Date: ${dateValue}\"
	https://${bucket}.s3.amazonaws.com/${filePath} " >> /tmp/s3-bootstrap.log
}

# Instance profile
roleProfile=$(curl -s http://169.254.169.254/latest/meta-data/iam/info \
	| grep -Eo 'instance-profile/([a-zA-Z0-9._-]+)' \
	| sed  's#instance-profile/##')

# AWS Account
accountId=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document \
	| grep -Eo '([[:digit:]]{12})')

# Bucket path for the cloud-config.yaml
bucket=${accountId}-CLUSTER-NAME-cloudinit

# Path to cloud-config.yaml
cloudConfigYaml="${roleProfile}/cloud-config.yaml"

# path to initial-cluster urls file
# This file is uploaded by [stakater/etcd-aws-cluster](https://hub.docker.com/r/stakater/etcd-aws-cluster/) image
# For more information refer to Tehcnical notes section in the project's README.md
initialCluster="CLUSTER-NAME_etcd/initial-cluster"

# Find token, AccessKeyId,  line, remove leading space, quote, commas
s3Token=$(get_value "Token")
s3Key=$(get_value "AccessKeyId")
s3Secret=$(get_value "SecretAccessKey")


########################################################################
# Download configuration files from s3 bucket and store under etc/
########################################################################

configDir="/etc/config"
mkdir -m 700 -p ${configDir}
cd ${configDir}

configBucket=${accountId}-CLUSTER-NAME-config

# TODO: dynamically download all config files
# TODO: download only if there is any config file!
# TODO: currently this is hardcoded which is poor practice and will work for elk only

# TODO: temporary hardcoded path to logstash config
logstashConfigFile="${roleProfile}/logstash.conf"

resource="/${configBucket}/${logstashConfigFile}"
create_string_to_sign
signature=$(/bin/echo -n "$stringToSign" | openssl sha1 -hmac ${s3Secret} -binary | base64)
filePath=${logstashConfigFile}
debug_log
curl -s -L -O -H "Host: ${configBucket}.s3.amazonaws.com" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  -H "x-amz-security-token:${s3Token}" \
  -H "Date: ${dateValue}" \
  https://${configBucket}.s3.amazonaws.com/${logstashConfigFile}

#######################################################################
# Download `upload-files.sh` from docker_registry to /etc/scripts
#
# Downloading this script will allow gen-certificate.service to generate
# certificates then upload them to s3
#######################################################################

scriptsDir="/etc/scripts"
mkdir -m 700 -p ${scriptsDir}
cd ${scriptsDir}

uploadScriptFile="CLUSTER-NAME_docker_registry/upload-files.sh"

resource="/${configBucket}/${uploadScriptFile}"
create_string_to_sign
signature=$(/bin/echo -n "$stringToSign" | openssl sha1 -hmac ${s3Secret} -binary | base64)
debug_log
curl -s -L -O -H "Host: ${configBucket}.s3.amazonaws.com" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  -H "x-amz-security-token:${s3Token}" \
  -H "Date: ${dateValue}" \
  https://${configBucket}.s3.amazonaws.com/${uploadScriptFile}

# make script file executable
chmod a+x upload-files.sh

#######################################################################
# Download registry certificate from docker_registry if it exists
#
#######################################################################

regCertDir="/etc/registry_certificates"
mkdir -m 700 -p ${regCertDir}
cd ${regCertDir}

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
if [ -f ${regCertDir}/ca.pem ] && grep -q "BEGIN CERTIFICATE" ${regCertDir}/ca.pem ;
then
  dockerCertDir="/etc/docker/certs.d/registry.CLUSTER-NAME.local:5000/"
  mkdir -p ${dockerCertDir}
  #NOTE: Rename the ca.pem file to ca.crt
  mv ${regCertDir}/ca.pem ${regCertDir}/ca.crt
  cp ${regCertDir}/ca.crt ${dockerCertDir}/ca.crt
else
  rm -f ${regCertFile}/*
fi

#######################################################################
# Download gocd configuration files if current module is gocd
#
# Download and place sudoers file in `/gocd-data/sudoers` to allow
# GoCD to use `sudo` without password
# Dowload and place `cruise-config.xml` to `/gocd-data/conf` to feed
# `cruise-config.xml` to GoCD at startup
#######################################################################

# If role profile is for gocd
if [[  $roleProfile == *"gocd"* ]] ;
then
  gocdDownloadDir="/gocd-downlaod"
  mkdir -m 700 -p ${gocdDownloadDir}
  cd ${gocdDownloadDir}

  # List of config files to download
  fileList+=()
  fileList+=("CLUSTER-NAME_gocd/conf/sudoers")
  fileList+=("CLUSTER-NAME_gocd/conf/cruise-config.xml")
  fileList+=("CLUSTER-NAME_gocd/conf/passwd")
  fileList+=("CLUSTER-NAME_gocd/route53/record-change-batch.json.tmpl")
  fileList+=("CLUSTER-NAME_gocd/route53/substitite-record-values.sh")
  fileList+=("CLUSTER-NAME_gocd/scripts/build-ami.sh")
  fileList+=("CLUSTER-NAME_gocd/scripts/build-docker-image.sh")
  fileList+=("CLUSTER-NAME_gocd/scripts/deploy-to-cluster.sh")
  fileList+=("CLUSTER-NAME_gocd/scripts/docker-cleanup.sh")
  fileList+=("CLUSTER-NAME_gocd/scripts/gocd.parameteres.txt")
  fileList+=("CLUSTER-NAME_gocd/scripts/read-parameter.sh")

  # Download all files in the list
  for f in "${fileList[@]}"
  do
    resource="/${configBucket}/$f"
    create_string_to_sign
    signature=$(/bin/echo -n "$stringToSign" | openssl sha1 -hmac ${s3Secret} -binary | base64)
    debug_log
    curl -s -L -O -H "Host: ${configBucket}.s3.amazonaws.com" \
      -H "Content-Type: ${contentType}" \
      -H "Authorization: AWS ${s3Key}:${signature}" \
      -H "x-amz-security-token:${s3Token}" \
      -H "Date: ${dateValue}" \
      https://${configBucket}.s3.amazonaws.com/${f}
  done

  # Create gocd data directory
  gocdDataDir="/gocd-data"
  mkdir ${gocdDataDir}

  # if sudoers file is downloaded and valid, copy to `gocd-data` directory
  if [ -f ${gocdDownloadDir}/sudoers ] && grep -q "go" ${gocdDownloadDir}/sudoers ;
  then
    sudoersDir="${gocdDataDir}/sudoers/"
    mkdir -p ${sudoersDir}
    cp ${gocdDownloadDir}/sudoers ${sudoersDir}/sudoers
  fi

  # if cruise-config file is downloaded and valid, copy to `gocd-data` directory
  if [ -f ${gocdDownloadDir}/cruise-config.xml ] && grep -q "pipeline" ${gocdDownloadDir}/cruise-config.xml ;
  then
    confDir="${gocdDataDir}/conf/"
    mkdir -p ${confDir}
    cp ${gocdDownloadDir}/cruise-config.xml ${confDir}/cruise-config.xml
    # Change permissions of conf directory and all of its contents (wanted by gocd server)
    chown -R 999:999 ${confDir}
  fi
  # if sudoers file is downloaded and valid, copy to `gocd-data` directory
  if [ -f ${gocdDownloadDir}/passwd ]  ;
  then
    cp ${gocdDownloadDir}/passwd ${gocdDataDir}/passwd
  fi

  # if record-change-batch.json.tmpl file is downloaded and valid, copy to `gocd-data` directory
  if [ -f ${gocdDownloadDir}/record-change-batch.json.tmpl ] && grep -q "ResourceRecordSet" ${gocdDownloadDir}/record-change-batch.json.tmpl ;
  then
    route53Dir="${gocdDataDir}/route53/"
    mkdir -p ${route53Dir}
    cp ${gocdDownloadDir}/record-change-batch.json.tmpl ${route53Dir}/record-change-batch.json.tmpl
  fi

  # if record-change-batch.json.tmpl file is downloaded and valid, copy to `gocd-data` directory
  if [ -f ${gocdDownloadDir}/substitite-record-values.sh ] ;
  then
    route53Dir="${gocdDataDir}/route53/"
    mkdir -p ${route53Dir}
    cp ${gocdDownloadDir}/substitite-record-values.sh ${route53Dir}/substitite-record-values.sh
  fi

  # if script files from script folder have been dwnloaded, copy to `gocd-data` directory
  gocdScriptsDir="${gocdDataDir}/scripts/"
  mkdir -p ${gocdScriptsDir}
  if [ -f ${gocdDownloadDir}/bake-ami.sh ] ;
  then
    cp ${gocdDownloadDir}/bake-ami.sh ${gocdScriptsDir}/bake-ami.sh
  fi
  if [ -f ${gocdDownloadDir}/build-docker-image.sh ] ;
  then
    cp ${gocdDownloadDir}/build-docker-image.sh ${gocdScriptsDir}/build-docker-image.sh
  fi
  if [ -f ${gocdDownloadDir}/deploy-to-cluster.sh ] ;
  then
    cp ${gocdDownloadDir}/deploy-to-cluster.sh ${gocdScriptsDir}/deploy-to-cluster.sh
  fi
  if [ -f ${gocdDownloadDir}/docker-cleanup.sh ] ;
  then
    cp ${gocdDownloadDir}/docker-cleanup.sh ${gocdScriptsDir}/docker-cleanup.sh
  fi
  if [ -f ${gocdDownloadDir}/gocd.parameters.txt ] ;
  then
    cp ${gocdDownloadDir}/gocd.parameters.txt ${gocdScriptsDir}/gocd.parameters.txt
  fi
  if [ -f ${gocdDownloadDir}/read-parameter.sh ] ;
  then
    cp ${gocdDownloadDir}/read-parameter.sh ${gocdScriptsDir}/read-parameter.sh
  fi

  # Delete temporary downloads folder
  rm -rf ${gocdDownloadDir}
fi

########################################################################
# Download CLUSTER-NAME-cloudinit/<profile>/clould-config.yaml
#
# And replace ipv4 vars in clould-config.yaml
# because oem-cloudinit.service does it only on native "user-data", i.e. this script.
########################################################################

workDir="/root/cloudinit"
mkdir -m 700 -p ${workDir}
cd ${workDir}

resource="/${bucket}/${cloudConfigYaml}"
create_string_to_sign
signature=$(/bin/echo -n "$stringToSign" | openssl sha1 -hmac ${s3Secret} -binary | base64)
filePath=${cloudConfigYaml}
debug_log
curl -L -s -H "Host: ${bucket}.s3.amazonaws.com" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  -H "x-amz-security-token:${s3Token}" \
  -H "Date: ${dateValue}" \
  https://${bucket}.s3.amazonaws.com/${cloudConfigYaml} \
  | sed "s/\\$private_ipv4/$private_ipv4/g; s/\\$public_ipv4/$public_ipv4/g" \
  > ${workDir}/cloud-config.yaml

# Download initial-cluster
resource="/${bucket}/${initialCluster}"
create_string_to_sign
signature=$(/bin/echo -n "$stringToSign" | openssl sha1 -hmac ${s3Secret} -binary | base64)
filePath=${initialCluster}
debug_log
curl -s -L -O -H "Host: ${bucket}.s3.amazonaws.com" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  -H "x-amz-security-token:${s3Token}" \
  -H "Date: ${dateValue}" \
  https://${bucket}.s3.amazonaws.com/${initialCluster}

# Copy initial-cluster to the volume that will be picked up by etcd boostraping
if [ -f ${workDir}/initial-cluster ] && grep -q ETCD_INITIAL_CLUSTER ${workDir}/initial-cluster ;
then
  mkdir -p /etc/sysconfig/
  cp ${workDir}/initial-cluster /etc/sysconfig/initial-cluster
fi

# Create /etc/environment file so the cloud-init can get IP addresses
coreos_env='/etc/environment'
if [ ! -f $coreos_env ];
then
    echo "COREOS_PRIVATE_IPV4=$private_ipv4" > /etc/environment
    echo "COREOS_PUBLIC_IPV4=$public_ipv4" >> /etc/environment
fi

# Copy the cloud-config file and replace it with the default cloud-config of coreos
# so that our cloud-config becomes the defualt cloud-config for the coreos machine
# Required when creating AMI so that all instances created from that AMI also have
# this cloud config as their default on startup
cp ${workDir}/cloud-config.yaml /usr/share/oem/cloud-config.yml

# Run cloud-init (explicitly)
coreos-cloudinit --from-file=${workDir}/cloud-config.yaml