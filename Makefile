.PHONY: init
init:
	@ansible-playbook \
		-l init \
		--tags init,install \
		ansible/playbook.yml

##########
# ISUCON #
##########
RSYNC_CMD := rsync -e "ssh -F $(CURDIR)/.ssh/config" --rsync-path "sudo rsync"
WEBAPP := isucon1
DB := isucon1

.PHONY: deploy
deploy:
	@ansible-playbook \
		-l webapp,db \
		--tags deploy \
		ansible/playbook.yml

.PHONY: bench
bench:
	@open https://portal.isucon.net/

.PHONY: access.jsonl.gz
access.jsonl.gz:
	@$(RSYNC) $(WEBAPP):/var/log/nginx/$@ .

.PHONY: slow.log.gz
slow.log.gz:
	@ssh -F .ssh/config $(DB) "sudo gzip -k --best /var/log/mysql/slow.log"
	@$(RSYNC) $(DB):/var/log/mysql/$@ .
