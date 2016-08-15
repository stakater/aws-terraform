## Multiple Core-OS clusters with a Single ETCD Cluster
The cluster in CoreOS is managed by fleet, if you want to see how, look under the 'hidden' etcd key ``
`/_coreos.com/fleet`

```
$ etcdctl ls /_coreos.com/fleet
/_coreos.com/fleet/machines
/_coreos.com/fleet/engine
/_coreos.com/fleet/lease
/_coreos.com/fleet/unit
/_coreos.com/fleet/job
/_coreos.com/fleet/state
/_coreos.com/fleet/states
```

You can change the key prefix used by fleet, then you will be able to have separate clusters using the same etcd.

The cloud-config section for fleet does support this via the etcd_key_prefix setting. By default this is `/_coreos.com/fleet/` so set this to a similar sort of value with a leading and trailing slash .

Each machine should have a configuration in something like `/run/systemd/system/fleet.service.d/20-cloudinit.conf` which includes a `FLEET_ETCD_KEY_PREFIX` environment variable. Then, you should be able to use etcdctl to view the key and verify fleetctl operations are working.


### NOTE:
While using `fleetctl` with custom etcd key prefix, you will have to specify the key prefix with the `fleetctl` command:
e.g:
```
fleetctl --etcd-key-prefix=/my/prefix/ list-units
```

For more information: https://coreos.com/os/docs/latest/cloud-config.html#fleet

