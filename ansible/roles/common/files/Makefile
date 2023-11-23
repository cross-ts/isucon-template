#
# Constants
#
ISUCON_USER := isucon
NGINX_LOG_FILE := /var/log/nginx/access.log
MYSQL_SLOW_LOG_FILE := /var/log/mysql/slow.log
MYSQL_SCHEMA_FILE := schema.sql
SERVER1 := isucon1
SERVER2 := isucon2
SERVER3 := isucon3

#
# Variables: 以下の変数は適宜変更する
#
APP_SERVER := $(SERVER1)
DB_SERVER := $(SERVER1)
MYSQL_USER := $(ISUCON_USER)
MYSQL_PWD := $(ISUCON_USER)
MYSQL_HOST := localhost
MYSQL_DB := $(ISUCON_USER)

#
# Remote Commands
#
.PHONY: init
init:
	@ssh $(SERVER1) 'make init-local' | tee $(MYSQL_SCHEMA_FILE)
	@ssh $(SERVER2) 'make init-local'
	@ssh $(SERVER3) 'make init-local'

.PHONY: alp
alp:
	@ssh $(APP_SERVER) 'make alp-local' | tee alp.log

.PHONY: pt
pt:
	@ssh $(DB_SERVER) 'make pt-local' | tee pt.log

.PHONY: migrate
migrate:
	@rsync -avz $(MYSQL_SCHEMA_FILE) $(DB_SERVER):$(MYSQL_SCHEMA_FILE)
	@ssh $(DB_SERVER) 'make migrate-local'

.PHONY: clean
clean:
	@ssh $(SERVER1) 'make clean-local'
	@ssh $(SERVER2) 'make clean-local'
	@ssh $(SERVER3) 'make clean-local'

#
# Local Commands
#
.PHONY: init-local
init-local:
	@sudo touch $(NGINX_LOG_FILE)
	@sudo touch $(MYSQL_SLOW_LOG_FILE)
	@sudo chmod 777 $(NGINX_LOG_FILE)
	@sudo chmod 777 $(MYSQL_SLOW_LOG_FILE)
	@mysqldef -u $(MYSQL_USER) -p $(MYSQL_PWD) -h $(MYSQL_HOST) --export $(MYSQL_DB)

.PHONY: alp-local
alp-local:
	@sudo alp --config alp.yml ltsv

.PHONY: pt-local
pt-local:
	@sudo cat $(MYSQL_SLOW_LOG_FILE) | pt-query-digest

.PHONY: migrate-local
migrate-local:
	@mysqldef -u $(MYSQL_USER) -p $(MYSQL_PWD) -h $(MYSQL_HOST) --file $(MYSQL_SCHEMA_FILE) $(MYSQL_DB)

.PHONY: clean-local
clean-local:
	@: | sudo tee $(NGINX_LOG_FILE)
	@: | sudo tee $(MYSQL_SLOW_LOG_FILE)
