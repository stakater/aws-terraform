#How to get meta information of your AWS machine

You can get information about your AWS machine by requesting the following url through `curl` from inside the machine.
```
http://169.254.169.254/latest/
```

This will return 
```
dynamic
meta-data
user-data
```

You can further curl into these rousources to get the information you need.0

Navigating into the meta-data resource, you can fetch information like, instance's ip address, IAM information, instance ID and etc.
It is extremely useful for debugging purposes and also when you need such information dynamically, you can fetch the resource through `curl` in a bash script.

e.g. 

If you want to feth the current instance's ID, region, availability zone etc, execute the following command from inside the machine:
```
curl http://169.254.169.254/latest/dynamic/instance-identity/document
```

Similarly you can view the current cloud-config file being used by the machine through:
```
curl http://169.254.169.254/latest/user-data/
```

#####NOTE: 
Make sure the URL has an ending `/` else it will return empty
