## How to access etcd and fleet inside docker container.

### FLEET
The best way have access to fleet inside a docker container is to map `fleetctl` inside the container so that all `fleetctl` commands can be run from inside the container as well.

To map fleetctl, add this to your docker options:
```
-v /usr/bin/fleetctl:/usr/bin/fleetctl
```

### ETCD
You can also map `etcdctl` the same way we mapped `fleetctl`, but `etcdctl` needs access to local endpoints `http://localhost:2379` and etc, if you are using `proxy`.

In that case, the best option is to use the etcd REST API, using the host-machine's ip address (from inside docker) as the endpoint.

The following command will return the host's ip from "inside" the docker container:
```
host_ip=$(ip route show | awk '/default/ {print $3}');
```

Now you can use this ip to query etcd's REST API:
```
curl -s -L http://${host_ip}:4001/v2/keys/myKey/
```