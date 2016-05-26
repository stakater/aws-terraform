snapshot: amicreation plan_snapshot
	cd $(BUILD); \
		$(TF_APPLY) -target module.snapshot

plan_snapshot: init_snapshot 
	cd $(BUILD); \
		$(TF_PLAN) -target module.snapshot;

refresh_snapshot: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.snapshot

destroy_snapshot: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_DESTROY) -target module.snapshot

clean_snapshot: destroy_snapshot
	rm -f $(BUILD)/module-snapshot.tf

init_snapshot: init
	cp -rf $(RESOURCES)/terraforms/module-snapshot.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

.PHONY: snapshot destroy_snapshot refresh_snapshot plan_snapshot init_snapshot clean_snapshot
