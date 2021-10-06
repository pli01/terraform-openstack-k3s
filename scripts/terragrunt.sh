#!/bin/bash

export TG_BIN="$(pwd)/bin/terragrunt"
export TERRAGRUNT_TFPATH="$(pwd)/bin/terraform"
# cache
export TF_DATA_DIR="$(pwd)/cache"
export TERRAGRUNT_DOWNLOAD="$(pwd)/.terragrunt-cache"
# 
# no interactive
export TF_INPUT="false"

#
export TF_CLI_ARGS="-no-color"
export TF_IN_AUTOMATION="true"
#export TERRAGRUNT_AUTO_INIT="false"
#export TERRAGRUNT_SOURCE_UPDATE="true"

# debug terraform command : TF_LOG=debug
export TF_LOG="${TF_LOG:-}"
# debug terragrunt : TERRAGRUNT_LOG=debug
export TERRAGRUNT_LOG="${TERRAGRUNT_LOG:+--terragrunt-log-level $TERRAGRUNT_LOG}"

# build terragrunt cli option
terragrunt_cli_opt="${TERRAGRUNT_LOG:+$terragrunt_cli_opt $TERRAGRUNT_LOG}"

workdir=${1:? $(basename $0) [workdir] [cmd] needed}
cmd=${2:? $(basename $0) [workdir] [cmd] needed}
TF_VAR_env=${TF_VAR_env:?TF_VAR_env variable needed}

cd $workdir || exit 1

#$TG_BIN run-all init ${terragrunt_cli_opt}
#$TG_BIN hclfmt ${terragrunt_cli_opt}
$TG_BIN run-all ${cmd} ${terragrunt_cli_opt}
