.PHONY: init
init:
	@ansible-playbook \
		-l init \
		--tags init,install \
		ansible/playbook.yml
