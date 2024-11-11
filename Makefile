.PHONY: init
init:
	@ansible-playbook \
		--tags init,install \
		ansible/playbook.yml
