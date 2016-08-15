worker_dev: vpc s3 iam route53 server_certificate plan_worker_dev upload_worker_dev_userdata
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c worker_dev; \
		$(TF_APPLY) -target module.worker_dev
	@$(MAKE) worker_dev_ips

plan_worker_dev: plan_vpc plan_s3 plan_iam plan_route53 plan_server_certificate init_worker_dev
	cd $(BUILD); \
		$(TF_PLAN) -target module.worker_dev;

refresh_worker_dev: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.worker_dev
	@$(MAKE) worker_dev_ips

destroy_worker_dev: | $(TF_PORVIDER)
	cd $(BUILD); \
	  $(SCRIPTS)/aws-keypair.sh -d worker_dev; \
		$(TF_DESTROY) -target module.worker_dev.aws_autoscaling_group.worker_dev; \
		$(TF_DESTROY) -target module.worker_dev.aws_launch_configuration.worker_dev; \
		$(TF_DESTROY) -target module.worker_dev

clean_worker_dev: destroy_worker_dev
	rm -f $(BUILD)/module-worker_dev.tf

init_worker_dev: init
	cp -rf $(RESOURCES)/terraforms/module-worker_dev.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

upload_worker_dev_userdata: init_build_dir
	cd $(BUILD); \
		$(SCRIPTS)/gen-userdata.sh ${CLUSTER_NAME}_worker_dev $(CONFIG)/cloudinit-worker_dev.def

worker_dev_ips:
	@echo "worker_dev public ips: " `$(SCRIPTS)/get-ec2-public-id.sh worker_dev`

.PHONY: worker_dev destroy_worker_dev refresh_worker_dev plan_worker_dev init_worker_dev clean_worker_dev upload_worker_dev_userdata worker_dev_ips