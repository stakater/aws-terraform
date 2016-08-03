worker_qa: vpc s3 iam plan_worker_qa upload_worker_qa_userdata
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c worker_qa; \
		$(TF_APPLY) -target module.worker_qa
	@$(MAKE) worker_qa_ips

plan_worker_qa: plan_vpc plan_s3 plan_iam init_worker_qa
	cd $(BUILD); \
		$(TF_PLAN) -target module.worker_qa;

refresh_worker_qa: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.worker_qa
	@$(MAKE) worker_qa_ips

destroy_worker_qa: | $(TF_PORVIDER)
	cd $(BUILD); \
	  $(SCRIPTS)/aws-keypair.sh -d worker_qa; \
		$(TF_DESTROY) -target module.worker_qa.aws_autoscaling_group.worker_qa; \
		$(TF_DESTROY) -target module.worker_qa.aws_launch_configuration.worker_qa; \
		$(TF_DESTROY) -target module.worker_qa

clean_worker_qa: destroy_worker_qa
	rm -f $(BUILD)/module-worker_qa.tf

init_worker_qa: init
	cp -rf $(RESOURCES)/terraforms/module-worker_qa.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

upload_worker_qa_userdata: init_build_dir
	cd $(BUILD); \
		$(SCRIPTS)/gen-userdata.sh ${CLUSTER_NAME}_worker_qa $(CONFIG)/cloudinit-worker_qa.def

worker_qa_ips:
	@echo "worker_qa public ips: " `$(SCRIPTS)/get-ec2-public-id.sh worker_qa`

.PHONY: worker_qa destroy_worker_qa refresh_worker_qa plan_worker_qa init_worker_qa clean_worker_qa upload_worker_qa_userdata worker_qa_ips