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

.PHONY: debug
debug:
	@echo $(LOG_BUCKET)

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
	@aws s3 cp $@ s3://$(LOG_BUCKET)/logs/nginx/$(shell gdate --iso-8601=seconds).jsonl.gz
	@ssh $(WEBAPP) "sudo truncate --size 0 /var/log/nginx/$@"

.PHONY: alp
alp:
	@duckdb -s "$(shell cat alp.sql)"

.PHONY: slow.log.gz
slow.log.gz:
	@ssh -F .ssh/config $(DB) "sudo gzip -k --best /var/log/mysql/slow.log"
	@$(RSYNC) $(DB):/var/log/mysql/$@ .
	@aws s3 cp $@ s3://$(LOG_BUCKET)/logs/mysql/$(shell gdate --iso-8601=seconds).log.gz

.PHONY: pt-query-digest
pt-query-digest:
	@gzcat slow.log.gz | pt-query-digest
