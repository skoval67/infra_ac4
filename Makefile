.PHONY: all build_infra run_playbook

all: build_infra run_playbook

build_infra:
	@cd terraform; \
		terraform plan; \
        terraform apply -auto-approve

run_playbook:
	@cd ansible; \
   		. venv/bin/activate; \
    	ansible-playbook -b playbook.yaml
