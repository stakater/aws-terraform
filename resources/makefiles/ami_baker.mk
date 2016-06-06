ami_baker: base_instance plan_ami_baker
	cd $(BUILD); \
		$(TF_APPLY) -target module.ami_baker

plan_ami_baker: init_ami_baker
	cd $(BUILD); \
		$(TF_PLAN) -target module.ami_baker;

refresh_ami_baker: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.ami_baker

destroy_ami_baker: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_DESTROY) -target module.ami_baker

clean_ami_baker: destroy_ami_baker
	rm -f $(BUILD)/module-ami_baker.tf

init_ami_baker: init
	cp -rf $(RESOURCES)/terraforms/module-ami_baker.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

.PHONY: ami_baker destroy_ami_baker refresh_ami_baker plan_ami_baker init_ami_baker clean_ami_baker
