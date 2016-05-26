GoCD in a Box
=================================

* [GoCD-Docker](https://github.com/gocd/gocd-docker)
* [GoCD Documentation](https://www.go.cd/documentation/user/current/)


Start GoCD Services
======================
    cd units
    fleetctl start gocd.service
    # wait for http://172.17.8.101:8153 is up
    fleetctl start gocd-agent-<agent-name>.service

check service status:
    fleetctl list-units
    fleetctl status gocd.service
    fleetctl status gocd-agent-<agent-name>.service

Reference: https://github.com/xuwang/coreos-docker-dev/tree/master/apps/gocd
