default: help
.PHONY: help
help:
	@echo "TODO: Write help message"

##########
# ISUCON #
##########
.PHONY: init
init:
	@ansible-playbook -l all ansible/init.yml

RSYNC := rsync -e "ssh -F $(CURDIR)/.ssh/config" --rsync-path "sudo rsync"
WEBAPP := isucon1
DB := isucon1

.PHONY: deploy
deploy:
	@ansible-playbook -l webapp,db ansible/deploy.yml

.PHONY: bench
bench:
	@open https://portal.isucon.net/

##################
# Logs: Download #
##################
NOW := $(shell gdate --iso-8601=seconds)
NGINX_LOG_FILE := /var/log/nginx/access.jsonl.gz
MYSQL_LOG_FILE := /var/log/mysql/slow.log

.PHONY: nginx-log
nginx-log:
	@$(RSYNC) $(WEBAPP):$(NGINX_LOG_FILE) logs/nginx/$(NOW).jsonl.gz
	@ssh $(WEBAPP) "sudo truncate --size 0 $(NGINX_LOG_FILE)"

.PHONY: mysql-log
mysql-log:
	@ssh -F .ssh/config $(DB) "sudo gzip -f -k --best $(MYSQL_LOG_FILE)"
	@$(RSYNC) $(DB):$(MYSQL_LOG_FILE).gz ./logs/mysql/$(shell gdate --iso-8601=seconds).log.gz
	@ssh $(DB) "sudo truncate --size 0 $(MYSQL_LOG_FILE)"

.PHONY: logs
logs: nginx-log mysql-log

#################
# Logs: Profile #
#################
LAST_NGINX_LOG_FILE = $(shell ls logs/nginx/*.jsonl.gz | tail -n 1)
LAST_MYSQL_LOG_FILE = $(shell ls logs/mysql/*.log.gz | tail -n 1)
DUCKDB_FILE := duckdb/local.duckdb

$(DUCKDB_FILE): duckdb/schema.sql
	@duckdb $(DUCKDB_FILE) -s "$(shell cat duckdb/schema.sql)"

access.jsonl.gz: logs/nginx/*.jsonl.gz
	@cp $(LAST_NGINX_LOG_FILE) ${@}

.PHONY: alp
alp: $(DUCKDB_FILE) duckdb/alp.sql access.jsonl.gz
	@duckdb $(DUCKDB_FILE) -s "$(shell cat duckdb/alp.sql)"

slow.log: logs/mysql/*.log.gz
	@cp $(LAST_MYSQL_LOG_FILE) ${@}.gz
	@gzip -d -f ${@}.gz

.PHONY: pt
pt: slow.log
	@pt-query-digest slow.log
