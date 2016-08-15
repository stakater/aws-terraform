server_certificate: plan_server_certificate
	cd $(BUILD); \
	$(TF_APPLY) -target module.server_certificate

plan_server_certificate: plan_vpc init_server_certificate
	cd $(BUILD); \
	$(TF_PLAN) -target module.server_certificate;

refresh_server_certificate: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_REFRESH) -target module.server_certificate

destroy_server_certificate: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_DESTROY) -target module.server_certificate;

clean_server_certificate: destroy_server_certificate
	rm -f $(BUILD)/module-server_certificate.tf

init_server_certificate: init
	cp -rf $(RESOURCES)/terraforms/module-server_certificate.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

.PHONY: server_certificate destroy_server_certificate refresh_server_certificate plan_server_certificate init_server_certificate clean_server_certificate

