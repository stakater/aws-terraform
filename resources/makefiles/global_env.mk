global_env: docker_registry route53 gocd worker_dev worker_qa

destroy_global_env: destroy_worker_dev destroy_worker_qa destroy_gocd destroy_route53 destroy_docker_registry

.PHONY: global_env destroy_global_env