amicreation: vpc plan_amicreation upload_amicreation_userdata
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c amicreation; \
		$(TF_APPLY) -target module.amicreation
	@$(MAKE) amicreation_ips

plan_amicreation: plan_vpc init_amicreation 
	cd $(BUILD); \
		$(TF_PLAN) -target module.amicreation;

refresh_amicreation: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.amicreation
	@$(MAKE) amicreation_ips

destroy_amicreation: | $(TF_PORVIDER)
	cd $(BUILD); \
	  $(SCRIPTS)/aws-keypair.sh -d amicreation; \
		$(TF_DESTROY) -target module.amicreation.aws_instance.amicreation; \
		$(TF_DESTROY) -target module.amicreation

clean_amicreation: destroy_amicreation
	rm -f $(BUILD)/module-amicreation.tf

init_amicreation: init
	cp -rf $(RESOURCES)/terraforms/module-amicreation.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

upload_amicreation_userdata: init_build_dir
	cd $(BUILD); \
		$(SCRIPTS)/gen-userdata.sh ${CLUSTER_NAME}_amicreation $(CONFIG)/cloudinit-amicreation.def
	sleep 30

amicreation_ips:
	@echo "amicreation public ips: " `$(SCRIPTS)/get-ec2-public-id.sh amicreation`

.PHONY: amicreation destroy_amicreation refresh_amicreation plan_amicreation init_amicreation clean_amicreation upload_amicreation_userdata amicreation_ips
