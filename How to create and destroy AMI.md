Before running make command for amicreation or snaphot please make sure file 'substitute-AZ-placeholder.sh' must have executable right permission. Further you can navigate to scripts directory and give executable rights to this file using this command.
```
chmod a+x substitute-AZ-placeholder.sh'
```

# Create Standalone Instance: 
```
make amicreation 
```
This will create a standalone instance with coreos image.

# Create AMI: 
```
make snapshot
```

This will create an instance with coreos image with predefined configuration files and systemd units. It will then create an AMI from that created instance. 

# Destroy Instance: 
```
make destroy_amicreation
```

This will destroy the standalone instance which we built using make amicreation command.

# Destroy Snapshot :
```
make destroy_snapshot
```
This will destroy the AMI and snapshots which we created as a result of make snaphot command.


