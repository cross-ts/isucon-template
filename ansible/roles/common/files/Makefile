#
# Constants
#
ISUCON_USER := isucon
NGINX_LOG_FILE := /var/log/nginx/access.log
MYSQL_SLOW_LOG_FILE := /var/log/mysql/slow.log
MYSQL_SCHEMA_FILE := schema.sql

#
# Variables: 以下の変数は適宜変更する
#
MYSQL_USER := $(ISUCON_USER)
MYSQL_PWD := $(ISUCON_USER)
MYSQL_HOST := localhost
MYSQL_DB := $(ISUCON_USER)

.PHONY: init
init:
	@sudo touch $(NGINX_LOG_FILE)
	@sudo touch $(MYSQL_SLOW_LOG_FILE)
	@sudo chmod 777 $(NGINX_LOG_FILE)
	@sudo chmod 777 $(MYSQL_SLOW_LOG_FILE)
	@mysqldef -u $(MYSQL_USER) -p $(MYSQL_PWD) -h $(MYSQL_HOST) --export $(MYSQL_DB) | tee $(MYSQL_SCHEMA_FILE)

.PHONY: alp
alp:
	@sudo alp --config alp.yml ltsv | tee alp.log

.PHONY: pt
pt:
	@sudo cat $(MYSQL_SLOW_LOG_FILE) | pt-query-digest | tee pt.log

.PHONY: migrate
migrate:
	@mysqldef -u $(MYSQL_USER) -p $(MYSQL_PWD) -h $(MYSQL_HOST) --file $(MYSQL_SCHEMA_FILE) $(MYSQL_DB)

.PHONY: clean
clean:
	@: | sudo tee $(NGINX_LOG_FILE)
	@: | sudo tee $(MYSQL_SLOW_LOG_FILE)
