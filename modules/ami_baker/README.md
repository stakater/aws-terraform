This module creates an AMI for the instance created from `base_instance`

#To create an instance and an AMI from that instance:
```
make ami_baker
```

This will create an instance (from the `base_instance` module) with coreos image with predefined configuration files and systemd units. Then it will then create an AMI from that created instance.

# Destroy AMI Baker :
```
make destroy_ami_baker
```

This will destroy the AMI and snapshots which we created as a result of make ami_baker command.




