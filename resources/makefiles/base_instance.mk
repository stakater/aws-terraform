#base_instance: vpc s3 iam plan_base_instance upload_base_instance_userdata
base_instance: iam plan_base_instance upload_base_instance_userdata
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c ${ENV_APP_NAME}_key; \
		$(TF_APPLY) -target module.base_instance
	@$(MAKE) base_instance_ips
	sleep 13600;

#plan_base_instance: plan_vpc plan_s3 plan_iam init_base_instance
plan_base_instance: plan_iam init_base_instance
	cd $(BUILD); \
		$(TF_PLAN) -target module.base_instance;

refresh_base_instance: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.base_instance
	@$(MAKE) base_instance_ips

destroy_base_instance: | $(TF_PORVIDER)
	cd $(BUILD); \
	  $(SCRIPTS)/aws-keypair.sh -d ${ENV_APP_NAME}_key; \
		$(TF_DESTROY) -target module.base_instance.aws_instance.base_instance; \
		$(TF_DESTROY) -target module.base_instance

clean_base_instance: destroy_base_instance
	rm -f $(BUILD)/module-base_instance.tf

init_base_instance: init
	cp -rf $(RESOURCES)/terraforms/module-base_instance.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

upload_base_instance_userdata: init_build_dir
	cd $(BUILD); \
		$(SCRIPTS)/gen-userdata.sh ${CLUSTER_NAME}_${ENV_APP_NAME} $(CONFIG)/cloudinit-base_instance.def

base_instance_ips:
	@echo "base_instance public ips: " `$(SCRIPTS)/get-ec2-public-id.sh base_instance`

.PHONY: base_instance destroy_base_instance refresh_base_instance plan_base_instance init_base_instance clean_base_instance upload_base_instance_userdata base_instance_ips
