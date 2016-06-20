admiral_global: pre_admiral_global route53 base_instance

pre_admiral_global: etcd plan_admiral_global upload_admiral_global_configs upload_admiral_global_userdata
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c admiral_global; \
		$(TF_APPLY) -target module.admiral_global
	@$(MAKE) admiral_global_ips

plan_admiral_global: plan_etcd init_admiral_global
	cd $(BUILD); \
		$(TF_PLAN) -target module.admiral_global;

refresh_admiral_global: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.admiral_global
	@$(MAKE) admiral_global_ips

destroy_admiral_global: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -d admiral_global; \
		$(TF_DESTROY) -target module.admiral_global.aws_autoscaling_group.admiral_global; \
		$(TF_DESTROY) -target module.admiral_global.aws_launch_configuration.admiral_global; \
		$(TF_DESTROY) -target module.admiral_global

clean_admiral_global: destroy_admiral_global
	rm -f $(BUILD)/module-admiral_global.tf

init_admiral_global: init
	cp -rf $(RESOURCES)/terraforms/module-admiral_global.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

admiral_global_ips:
	@echo "admiral_global public ips: " `$(SCRIPTS)/get-ec2-public-id.sh admiral_global`

upload_admiral_global_userdata: init_build_dir
	cd $(BUILD); \
		$(SCRIPTS)/gen-userdata.sh ${CLUSTER_NAME}_admiral_global $(CONFIG)/cloudinit-admiral_global.def
		# uploads confing folder to config s3 bucket; by keeping the folder structure

upload_admiral_global_configs:
	$(SCRIPTS)/upload-config.sh ${CLUSTER_NAME}_admiral_global $(RESOURCE_SCRIPTS)/upload-files.sh

.PHONY: admiral_global pre_admiral_global destroy_admiral_global refresh_admiral_global plan_admiral_global init_admiral_global clean_admiral_global upload_admiral_global_configs upload_admiral_global_userdata admiral_global_ips