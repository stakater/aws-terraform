NOTE: Make sure the `ExecStart` tag inside the unit file runs docker through "/usr/bin/sh -c", otherwise it won't be able to process the options from the variable and throw an error like: "flag provided but not defined: "

like: `ExecStart=/usr/bin/sh -c "/usr/bin/docker run  --rm --name %n ${LOGSTASH_OPTS} ${LOGSTASH_IMAGE} logstash"`
and NOT like: `ExecStart=/usr/bin/docker run  --rm --name %n ${LOGSTASH_OPTS} ${LOGSTASH_IMAGE} logstash`
