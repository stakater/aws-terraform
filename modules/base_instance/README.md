This module creates a base instance for the application, from which an AMI will be created.

# Prerequisites:
This module requires the following Environment variables to be defined:

```
ENV_VPC_ID: ID of the VPC in which the instance is to be created
ENV_VPC_CIDR: CIDR of the VPC in which the instance is to be created
ENV_SUBNET_ID: ID of the subnet in which the instance is to be created
ENV_AVAIL_ZONE: Availability zone in which the instance is to be created
ENV_APP_NAME: Name of the application, which is going to be the included in the name of resources created as well
ENV_APP_VERSION: Version of the application for which the instance is being created
APP_DOCKER_IMAGE: Name of the docker image which is going to run in the instance
APP_DOCKER_OPTS: Docker options for the docker run command of the given docker image
```

# Create Standalone Instance:
```
make base_instance
```
This will create a standalone instance with coreos image.

# Destroy Instance:
```
make destroy_base_instance
```

This will destroy the base instance.