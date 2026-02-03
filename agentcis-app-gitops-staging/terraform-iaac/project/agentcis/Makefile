TF = terraform
DEV_DIR         = environment/dev
STAGING_DIR     = environment/staging
PRODUCTION_DIR  = environment/production

.PHONY: init \
        plan-dev apply-dev destroy-dev \
        plan-staging apply-staging destroy-staging \
        plan-production apply-production destroy-production

# Development environment
init-dev:
	$(TF) init -backend-config=$(DEV_DIR)/backend.hcl

plan-dev:
	$(TF) plan -var-file=$(DEV_DIR)/terraform.tfvars

apply-dev:
	$(TF) apply -var-file=$(DEV_DIR)/terraform.tfvars

destroy-dev:
	$(TF) destroy -var-file=$(DEV_DIR)/terraform.tfvars

# Staging environment
init-staging:
	$(TF) init -backend-config=$(STAGING_DIR)/backend.hcl

plan-staging:
	$(TF) plan -var-file=$(STAGING_DIR)/terraform.tfvars

apply-staging:
	$(TF) apply -var-file=$(STAGING_DIR)/terraform.tfvars

destroy-staging:
	$(TF) destroy -var-file=$(STAGING_DIR)/terraform.tfvars

# Production environment
init-production:
	$(TF) init -backend-config=$(PRODUCTION_DIR)/backend.hcl

plan-production:
	$(TF) plan -var-file=$(PRODUCTION_DIR)/terraform.tfvars

apply-production:
	$(TF) apply -var-file=$(PRODUCTION_DIR)/terraform.tfvars

destroy-production:
	$(TF) destroy -var-file=$(PRODUCTION_DIR)/terraform.tfvars
