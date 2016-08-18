application_launcher: vpc s3 iam route53 server_certificate plan_application_launcher
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c application_launcher; \
		$(TF_APPLY) -target module.application_launcher
	@$(MAKE) application_launcher_ips
	@$(MAKE) application_launcher_elb_names

plan_application_launcher: plan_vpc plan_s3 plan_iam plan_route53 plan_server_certificate init_application_launcher
	cd $(BUILD); \
		$(TF_PLAN) -target module.application_launcher;

refresh_application_launcher: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.application_launcher
	@$(MAKE) application_launcher_ips
	@$(MAKE) application_launcher_elb_names

destroy_application_launcher: | $(TF_PORVIDER)
	cd $(BUILD); \
	  $(SCRIPTS)/aws-keypair.sh -d application_launcher; \
		$(TF_DESTROY) -target module.application_launcher.aws_autoscaling_group.application_launcher; \
		$(TF_DESTROY) -target module.application_launcher.aws_launch_configuration.application_launcher; \
		$(TF_DESTROY) -target module.application_launcher

clean_application_launcher: destroy_application_launcher
	rm -f $(BUILD)/module-application_launcher.tf

init_application_launcher: init
	cp -rf $(RESOURCES)/terraforms/module-application_launcher.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

application_launcher_ips:
	@echo "application_launcher public ips: " `$(SCRIPTS)/get-ec2-public-id.sh application_launcher`

application_launcher_elb_names:
	@echo ELB names: `aws elb describe-load-balancers --profile $(AWS_PROFILE) | jq --raw-output '.LoadBalancerDescriptions[].DNSName'`

.PHONY: application_launcher destroy_application_launcher refresh_application_launcher plan_application_launcher init_application_launcher clean_application_launcher application_launcher_ips application_launcher_elb_names
