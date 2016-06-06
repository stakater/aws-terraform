#To create an instance and an AMI from that instance: 
```
make snapshot
```

This will create an instance (from the `amicreation` module) with coreos image with predefined configuration files and systemd units. Then it will then create an AMI from that created instance. 

# Destroy Snapshot :
```
make destroy_snapshot
```

This will destroy the AMI and snapshots which we created as a result of make snaphot command.


# Create Standalone Instance: 
```
make amicreation 
```
This will create a standalone instance with coreos image.

# Destroy Instance: 
```
make destroy_amicreation
```

This will destroy the standalone instance which we built using make amicreation command.




