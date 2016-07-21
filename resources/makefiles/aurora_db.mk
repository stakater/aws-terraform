aurora_db: vpc plan_aurora_db
	echo "This module is Work In Progress, It is not supported untill stakater upgrades to Terraform 0.7 or greater"
	cd $(BUILD); \
	$(TF_APPLY) -target module.aurora_db
#TODO: make route53 too if using route53 in module

plan_aurora_db: plan_vpc init_aurora_db
	cd $(BUILD); \
	$(TF_PLAN) -target module.aurora_db;

refresh_aurora_db: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_REFRESH) -target module.aurora_db

destroy_aurora_db: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_DESTROY) -target module.aurora_db; \
	rm -f $(CONFIG)/aws-files.yaml

clean_aurora_db: destroy_aurora_db
	rm -f $(BUILD)/module-aurora_db.tf

init_aurora_db: init
	cp -rf $(RESOURCES)/terraforms/module-aurora_db.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

gen_aurora_db_pass:
	# Todo: generate or get db_user/db_password

.PHONY: aurora_db destroy_aurora_db refresh_aurora_db plan_aurora_db init_aurora_db clean_aurora_db
