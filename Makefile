SHELL = /bin/bash
PROJECT ?= terraform

# terraform config vars
TF_LOG ?= # debug
TF_BIN ?= $(shell type -p terraform)
TF_BIN_VERSION :=
TAINT_ADDRESS :=

TF_VAR_FILE ?= # -var-file=$(pwd)/config.auto.tfvars
TF_DATA_DIR ?= $(shell pwd)/cache
TF_IN_AUTOMATION ?= true
TF_CLI_ARGS ?= -no-color
TF_CLI_ARGS_init ?=
TF_CLI_ARGS_validate ?=
TF_CLI_ARGS_plan    ?= ${TF_VAR_FILE}
TF_CLI_ARGS_apply   ?= ${TF_VAR_FILE} -auto-approve
TF_CLI_ARGS_destroy ?= ${TF_VAR_FILE} -auto-approve
TF_CLI_ARGS_show    ?=
TF_CLI_ARGS_output  ?=

# terragrunt
TG_BIN_VERSION :=
TERRAGRUNT_TFPATH := ${TF_BIN}
TERRAGRUNT_DOWNLOAD := $(shell pwd)/.terragrunt-cache
TF_INPUT := # true

# docker-compose vars
DC       := $(shell type -p docker-compose)
DC_BUILD_ARGS := --pull --no-cache --force-rm
DC_TF_DOCKER_CLI := docker-compose.yml
DC_TF_ENV :=  #-f docker-compose.test.yml
DC_RUN_ARGS := -T

# extract PROJECT_BASENAME from PROJECT to source docker env file
PROJECT_BASENAME=$(shell basename ${PROJECT} 2>&-  ||true)
dummy_cnf := $(shell touch $(PROJECT_BASENAME).env )
export

check-var-%:
	@: $(if $(value $*),,$(error $* is undefined))

all:
	@echo "Usage: make PROJECT='myapp' build | deploy | destroy"
display:
	@echo "${PROJECT} ${PROJECT_BASENAME}"
	@env |grep "^TF"
#
# terraform build ci tool
#
build:
	${DC} -f ${DC_TF_DOCKER_CLI}  build ${DC_BUILD_ARGS}
install-tf:
	@scripts/install-terraform.sh ${TF_BIN_VERSION}
install-tg:
	@scripts/install-terragrunt.sh ${TG_BIN_VERSION}
#
# launch terraform with docker-compose
#
tf-config:
	@${DC} -f ${DC_TF_DOCKER_CLI} ${DC_TF_ENV} config -q
tf-version:
	${DC} -f ${DC_TF_DOCKER_CLI} ${DC_TF_ENV} run --rm terraform -c 'terraform version'

tf-%:| check-var-PROJECT tf-config
	@echo "# start $*"
	${DC} -f ${DC_TF_DOCKER_CLI} ${DC_TF_ENV} run ${DC_RUN_ARGS} -w "/data" --rm terraform -c 'make PROJECT=${PROJECT} TAINT_ADDRESS=${TAINT_ADDRESS} $*'
	@echo "# end $*"
#
# terraform deploy
#
deploy:  init validate plan apply

pre-init: display
	echo "# ${TF_DATA_DIR}"
	[ -z "${TF_DATA_DIR}" ] && mkdir -p ${TF_DATA_DIR} || true
init:| check-var-PROJECT pre-init
	${TF_BIN} -chdir=${PROJECT} init
format:| check-var-PROJECT init
	${TF_BIN} -chdir=${PROJECT} fmt -check || ${TF_BIN} -chdir=${PROJECT} fmt -diff
validate:| check-var-PROJECT init
	${TF_BIN} -chdir=${PROJECT} validate
plan:| check-var-PROJECT init
	${TF_BIN} -chdir=${PROJECT} plan
apply:| check-var-PROJECT plan
	${TF_BIN} -chdir=${PROJECT} apply
destroy:| check-var-PROJECT init
	${TF_BIN} -chdir=${PROJECT} destroy
output:| check-var-PROJECT init
	${TF_BIN} -chdir=${PROJECT} output
show:| check-var-PROJECT init
	${TF_BIN} -chdir=${PROJECT} show
state:| check-var-PROJECT init
	${TF_BIN} -chdir=${PROJECT} state list
show-json:| check-var-PROJECT init
	${TF_BIN} -chdir=${PROJECT} show  -json | \
	   jq -re  '.values' | sort
#	   jq -re  '.values.root_module.child_modules[].child_modules[].resources[]|(.name + ": "+.address)' | sort

taint:| check-var-PROJECT init
	for val in $$(echo "${TAINT_ADDRESS}" |tr -d '[:space:]' | tr ',' '\n'); do \
           echo "# $${val}" ; \
           ${TF_BIN} -chdir=${PROJECT} taint -allow-missing "$${val}" ; \
        done
