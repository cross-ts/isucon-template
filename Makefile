default: help
.PHONY: help
help:
	@echo "TODO: Write help message"

###############
# Preparation #
###############
LOG_BUCKET = $(shell aws cloudformation describe-stacks --stack-name ProfilerStack --query 'Stacks[0].Outputs[?ExportName==`LogBucketName`].OutputValue' --output text)
.PHONY: cdk-deploy
.ONESHELL: cdk-deploy
cdk-deploy:
	@cd cdk
	@npx cdk deploy \
		--require-approval never \
		--no-lookups

.PHONY: cdk-destroy
.ONESHELL: cdk-destroy
cdk-destroy:
	@cd cdk
	@npx cdk destroy \
		--require-approval never \
		--no-lookups

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

.PHONY: post-bench
post-bench:
	@$(MAKE) access.jsonl.gz slow.log.gz

.PHONY: access.jsonl.gz
access.jsonl.gz:
	@$(RSYNC) $(WEBAPP):/var/log/nginx/$@ ./logs/nginx/$(shell gdate --iso-8601=seconds).jsonl.gz
	@ssh $(WEBAPP) "sudo truncate --size 0 /var/log/nginx/$@"

.PHONY: slow.log.gz
slow.log.gz:
	@ssh -F .ssh/config $(DB) "sudo gzip -f -k --best /var/log/mysql/slow.log"
	@$(RSYNC) $(DB):/var/log/mysql/$@ ./logs/mysql/$(shell gdate --iso-8601=seconds).log.gz
	@ssh $(DB) "sudo truncate --size 0 /var/log/mysql/slow.log"

.PHONY: alp
alp:
	@duckdb -s "$(shell cat alp.sql)"

.PHONY: pt-query-digest
pt-query-digest:
	@gzcat slow.log.gz | pt-query-digest
