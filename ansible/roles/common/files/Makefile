#
# Constants
#
NGINX_LOG_FILE = /var/log/nginx/access.log
MYSQL_SLOW_LOG_FILE = /var/log/mysql/slow.log

.PHONY: init
init:
	@sudo touch $(NGINX_LOG_FILE)
	@sudo touch $(MYSQL_SLOW_LOG_FILE)
	@sudo chmod 777 $(NGINX_LOG_FILE)
	@sudo chmod 777 $(MYSQL_SLOW_LOG_FILE)

.PHONY: alp
alp:
	@sudo alp --config alp.yml ltsv | tee alp.log

.PHONY: pt
pt:
	@sudo cat $(MYSQL_SLOW_LOG_FILE) | pt-query-digest | tee pt.log
