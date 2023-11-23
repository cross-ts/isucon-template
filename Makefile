#
# Environment variables
#
export ANSIBLE_HOST_KEY_CHECKING=False

#
# Targets
#
.PHONY: ansible
ansible:
	@ansible-playbook -i ansible/inventory ansible/playbook.yml
