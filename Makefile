default: help
.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo
	@echo "Targets:"
	@echo "  prepare  Install dependencies"
	@echo "  init     Initialize environment"
	@echo "  deploy   Deploy application"
	@echo "  bench    Run benchmark"
	@echo "  alp      Analyze access log"
	@echo "  pt-query-digest  Analyze slow query log"

#################
# Prepare Tasks #
#################
cdk/node_modules:
	@cd cdk && npm ci

.PHONY: prepare
.ONESHELL:
prepare: cdk/node_modules
	@cd cdk && pwd

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
	@gzcat slow.log.gz | pt-query-digest
