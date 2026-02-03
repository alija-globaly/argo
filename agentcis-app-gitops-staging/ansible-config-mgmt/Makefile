SHELL := /bin/bash

.DEFAULT_GOAL := help

ping-detailed:
	docker compose run --rm ansible \
		sh -c "ANSIBLE_STDOUT_CALLBACK=default \
		ansible all -m setup -a "filter=ansible_hostname" | grep -E hostname"
ping-host:
	docker compose run --rm ansible sh -c "ANSIBLE_STDOUT_CALLBACK=default ansible all -m ping"
ec2-create:
	docker compose run --rm ansible \
		sh -c \
		"pip install boto3 botocore && \
		ansible-galaxy collection install amazon.aws && \
		ansible-playbook ec2-create-main.yml"
ec2-delete:
	docker compose run --rm ansible \
		sh -c \
		"pip install boto3 botocore && \
		ansible-galaxy collection install amazon.aws && \
		ansible-playbook main/ec2-delete-main.yml"
setup-k8s:
	docker compose run --rm ansible \
		sh -c "ansible-playbook main.yml"
setup-argocd:
	docker compose run --rm ansible sh -c "ansible-playbook main/argocd-setup.yml"
delete-container:
	docker compose down --remove-orphans
