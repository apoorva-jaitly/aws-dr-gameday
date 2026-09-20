SHELL := /bin/sh
TF_DIR := terraform/environments/dev
TF := terraform -chdir=$(TF_DIR)
DESTROY_PLAN_FILE := phase1-destroy.tfplan

.PHONY: fmt fmt-check init validate plan apply plan-destroy destroy output

fmt:
	terraform fmt -recursive terraform

fmt-check:
	terraform fmt -check -recursive terraform

init:
	$(TF) init

validate: init
	$(TF) validate

plan: validate
	$(TF) plan

apply: fmt-check validate
	$(TF) apply

plan-destroy: init
	$(TF) plan -destroy -out=$(DESTROY_PLAN_FILE)

destroy:
	$(TF) destroy

output:
	$(TF) output
