This module creates a base instance for the application, from which an AMI will be created.

# Create Standalone Instance:
```
make base_instance
```
This will create a standalone instance with coreos image.

# Destroy Instance:
```
make destroy_base_instance
```

This will destroy the standalone instance which we built using make amicreation command.