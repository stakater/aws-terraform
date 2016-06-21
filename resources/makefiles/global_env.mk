global_env: docker_registry route53 gocd

destroy_global_env: destroy_gocd destroy_route53 destroy_docker_registry

.PHONY: global_env destroy_global_env