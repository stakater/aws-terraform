docker_registry: etcd route53 plan_docker_registry upload_docker_registry_configs upload_docker_registry_userdata
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c docker_registry; \
		$(TF_APPLY) -target module.docker_registry
	@$(MAKE) docker_registry_ips

plan_docker_registry: plan_etcd plan_route53 init_docker_registry
	cd $(BUILD); \
		$(TF_PLAN) -target module.docker_registry;

refresh_docker_registry: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.docker_registry
	@$(MAKE) docker_registry_ips

destroy_docker_registry: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -d docker_registry; \
		$(TF_DESTROY) -target module.docker_registry.aws_autoscaling_group.docker_registry; \
		$(TF_DESTROY) -target module.docker_registry.aws_launch_configuration.docker_registry; \
		$(TF_DESTROY) -target module.docker_registry

clean_docker_registry: destroy_docker_registry
	rm -f $(BUILD)/module-docker_registry.tf

init_docker_registry: init
	cp -rf $(RESOURCES)/terraforms/module-docker_registry.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

docker_registry_ips:
	@echo "docker_registry public ips: " `$(SCRIPTS)/get-ec2-public-id.sh docker_registry`

upload_docker_registry_userdata: init_build_dir
	cd $(BUILD); \
		$(SCRIPTS)/gen-userdata.sh ${CLUSTER_NAME}_docker_registry $(CONFIG)/cloudinit-docker_registry.def
		# uploads confing folder to config s3 bucket; by keeping the folder structure

upload_docker_registry_configs:
	$(SCRIPTS)/upload-config.sh ${CLUSTER_NAME}_docker_registry $(RESOURCE_SCRIPTS)/upload-files.sh

.PHONY: docker_registry pre_docker_registry destroy_docker_registry refresh_docker_registry plan_docker_registry init_docker_registry clean_docker_registry upload_docker_registry_configs upload_docker_registry_userdata docker_registry_ips