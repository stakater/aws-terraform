This module launches instance(s) in an auto scaling group, from the AMI created from `ami_baker` module.

This module is Work In Progress, there are issues creating autoscaling group and launch configuration from our AMI, through terraform.

[https://github.com/hashicorp/terraform/issues/7024](https://github.com/hashicorp/terraform/issues/7024)


# Launch instance(s) in an auto scaling group, via launch configuration:
```
make application_launcher
```
This will create a launch configuration, auto scaling group and launch instance(s) according to the launch configuration.

# Destroy instance(s), auto scaling group and launch configuration:
```
make destroy_application_launcher
```

This will destroy the instance(s), auto scaling group and launch configuration