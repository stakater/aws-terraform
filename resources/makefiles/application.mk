application: ami_baker plan_application
	echo "This module is Work In Progress, there are issues creating autoscaling group and launch configuration from our AMI, through terraform"
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c application; \
		$(TF_APPLY) -target module.application
	@$(MAKE) application_ips

plan_application: init_application
	cd $(BUILD); \
		$(TF_PLAN) -target module.application;

refresh_application: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.application
	@$(MAKE) application_ips

destroy_application: | $(TF_PORVIDER)
	cd $(BUILD); \
	  $(SCRIPTS)/aws-keypair.sh -d application; \
		$(TF_DESTROY) -target module.application.aws_autoscaling_group.application; \
		$(TF_DESTROY) -target module.application.aws_launch_configuration.application; \
		$(TF_DESTROY) -target module.application

clean_application: destroy_application
	rm -f $(BUILD)/module-application.tf

init_application: init
	cp -rf $(RESOURCES)/terraforms/module-application.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

application_ips:
	@echo "application public ips: " `$(SCRIPTS)/get-ec2-public-id.sh application`

.PHONY: application destroy_application refresh_application plan_application init_application clean_application application_ips
