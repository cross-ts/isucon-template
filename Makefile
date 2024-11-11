.PHONY: init
init:
	@ansible-playbook \
		--tags init \
		ansible/playbook.yml
