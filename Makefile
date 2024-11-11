.PHONY: init
init:
	@ansible-playbook \
		--tags install \
		ansible/playbook.yml
