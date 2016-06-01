#How to use `Fleetctl` Remotely
`Fleetctl` can be used to remotely submit and start units on a machine, or list-units.

###Prerequisites

#####ETCD Setup:
* Make sure `etcd2` and `fleet` serivces are running
* In the `cloud-config` file, make sure etcd has a discovery and proxy off
* Also make sure that listen client URLs are specified

```
coreos:
  etcd2:
    discovery: https://discovery.etcd.io/aadca8ea7e01a1ef5d7c28a16c708c58
    listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
```
by defualt proxy is off unless specified by `proxy: on` 

#####FLEET Setup:
* Make sure public IP and metadata for fleet are porvided in the cloud config file as:
```
  fleet:
    public-ip: $private_ipv4
    metadata: "env=CLUSTER-NAME,platform=ec2,provider=aws,role=admiral"
```
#####Port
* Make sure the machine from which the `fleetctl` commands will be sent has access to the server's port `4001` as fleet will be using this port.


###Using `fleetctl`
* Install `fleet` on the acccessing machine
for ubuntu:
```
apt-get install fleet
```

* There are two ways to tell fleet which machine are you going to access through fleet
  1. Set an environment vairable `FLEETCTL_ENDPOINT` and assign it the value of the public ip and port of the machine which we are going to access
  example:
    ```
    export FLEETCTL_ENDPOINT=http://12.34.56.78:4001
    ```
    and then you can 
    ```
    fleetctl list-units
    ```
    
  2. Specifiy the location of the machine with the `fleetctl` command:
    ```
    fleetctl --endpoint=http://12.34.56.78:4001 list
    ```
