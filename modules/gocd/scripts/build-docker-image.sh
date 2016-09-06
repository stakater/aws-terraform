#!/bin/bash
# This shell script builds docker image
#--------------------------------------------
# Argument1: ENVIRONMENT
# Argument2: APP_IMAGE_BUILD_VERSION
# Argument3: APP_DOCKER_IMAGE
#--------------------------------------------

# Get parameter values
APP_NAME=`/gocd-data/scripts/read-parameter.sh APP_NAME`
ENVIRONMENT=$1
APP_IMAGE_BUILD_VERSION=$2
APP_DOCKER_IMAGE=$3

# Package
# Run  docker-compose file
if [ $ENVIRONMENT == "prod" ]
then
   sudo /opt/bin/docker-compose -f docker-compose-prod.yml up
elif [ $ENVIRONMENT == "dev" ]
then
   sudo /opt/bin/docker-compose -f docker-compose-dev.yml up
elif [ $ENVIRONMENT == "test" ]
then
   sudo /opt/bin/docker-compose -f docker-compose-test.yml up
fi;

# Copy war file to root directory
sudo cp -f /app/${APP_NAME}/*.war ./

# Publish
# Build image
sudo docker build -t ${APP_DOCKER_IMAGE} -f Dockerfile_deploy .

# Push docker image
sudo docker push ${APP_DOCKER_IMAGE}

newTag=${APP_DOCKER_IMAGE}:${APP_IMAGE_BUILD_VERSION}
echo ${newTag}
sudo docker tag -f ${APP_DOCKER_IMAGE} ${newTag}
sudo docker push ${newTag}

# Delete empty docker images
/gocd-data/scripts/docker-cleanup.sh
