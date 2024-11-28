default: help
.PHONY: help
help:
	@echo "TODO: Write help message"

#################
# Prepare Tasks #
#################
cdk/node_modules:
	@cd cdk && npm ci

.PHONY: prepare
.ONESHELL: prepare
prepare: cdk/node_modules
	@cd cdk
	@npx cdk deploy --require-approval never

.PHONY: prepare-destructive
.ONESHELL: prepare-destructive
prepare-destructive: cdk/node_modules
	@cd cdk
	@npx cdk destroy --force

###############
# Setup Tasks #
###############
.PHONY: init
init:
	@ansible-playbook \
		-l init \
		--tags init,install \
		ansible/playbook.yml

##########
# ISUCON #
##########
RSYNC := rsync -e "ssh -F $(CURDIR)/.ssh/config" --rsync-path "sudo rsync"
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

.PHONY: alp
alp:
	@duckdb -s "$(shell cat alp.sql)"

.PHONY: slow.log.gz
slow.log.gz:
	@ssh -F .ssh/config $(DB) "sudo gzip -k --best /var/log/mysql/slow.log"
	@$(RSYNC) $(DB):/var/log/mysql/$@ .

.PHONY: pt-query-digest
pt-query-digest:
	@gzcat slow.log.gz | pt-query-digest --output json | tail -n +2
