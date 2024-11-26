.PHONY: init
init:
	@ansible-playbook \
		-l init \
		--tags init,install \
		ansible/playbook.yml

.PHONY: deploy
deploy:
	@ansible-playbook \
		-l webapp,db \
		--tags deploy \
		ansible/playbook.yml
